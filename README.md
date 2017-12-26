# Nestyards Developer Guide (Android)


## Arsitektur Utama

`Activity` - `View` (Fragment) - `Contract` - `Presenter` - `Model` (Java Class Model)

Setiap `View` seharusnya ditampilkan pada sebuah `Activity`.

Setiap `View` seharusnya mengandung satu `Model` yang akan ditampilkan.

Setiap `View` seharusnya tidak mengontrol `Model`, kontrol seharusnya dilakukan oleh `Presenter`. Kontrol yang dimaksud berupa CRUD (create, retrieve, update, delete).

`Activity` digunakan sebagai kontainer utama untuk menampilkan `View`. 

Setiap `View` dan `Presenter` dihubungkan melalui sebuah interface `Contract`

## Contoh Implementasi
Task: membuat tampilan screen Profile untuk menampilkan profile user.


Jenis | Penjelasan
-- | --
`Activity` | berupa activity profile sebagai kontainer utama (rekomendasi gunakan template activity yang disediakan android studio).
`View` | berupa fragment sebagai tempat untuk menampilkan screen Profile (xml file untuk screen profile ditaruh disini).
`Presenter` | berupa pengontrol seluruh data yang keluar masuk pada `View`.
`Model` | model profile berupa Java Class Model. Salah satu rekomendasi untuk membuat Java Class Model menggunakan [www.jsonschema2pojo.org](http://www.jsonschema2pojo.org)
`Contract` | sebagai interface untuk menghubungkan `View` dan `Presenter`.


### 1. Pre Task

Sebelum memulai membuat screen (Activity dan Fragment), lakukan persiapan metode koneksi ke server.

`GET: /user/profile?id=[id user]`

Buat sebuah model java misal dengan nama `GetUser.java`

**Model**
```java
public class GetUser implements Serializable, Parcelable{

    @SerializedName("_id")
    @Expose
    private String id;
    @SerializedName("updatedAt")
    @Expose
    private String updatedAt;
    @SerializedName("createdAt")
    @Expose
    private String createdAt;

    // ... atribut-atribut lain
	// konstruktor
	// getter
	// setter
	// method lain

}
```

Buat template model respon yang telah dibuat sebelumnya agar model `GetUser.java` dapat digunakan pada retrofit, misal dengan nama `GetUserResponse.java` seperti dibawah

```java
public class GetUserResponse extends APIGetResponse<GetUser> {}
```

Buat sebuah implementable method interface baru sesuai `GET: /user/profile?id=[id user]` dan respon menggunakan template model retrofit `GetUserResponse.java` pada kumpulan method pada interface retrofit di `data/network/RESTClient.java`

```java
// ...

@GET("/user/profile")
Call<GetUserResponse> getUser(@Header("Authorization") String authorization, @Query("id") String id);

// setiap koneksi wajib menyelipkan autorisasi pada header berupa token user (didapat ketika login atau register)

// ...
```

Lalu buat method untuk melakukan koneksi ke server dan realisasikan method interface diatas pada kelas `util/RESTHelper.java`
```java
public void getUser(final String auth, final String id, final GetCallbackListener callback){
    Call<GetUserResponse> call = mClient.getUser("Bearer " + auth, id);
    call.enqueue(new Callback<GetUserResponse>() {
        @Override
        public void onResponse(Call<GetUserResponse> call, Response<GetUserResponse> response) {

        	// handling jika koneksi tidak mengembalikan apa-apa
            if(response.body() == null)
                callback.onLoadFailed("Error: unknown");

            // handling jika response dari server menyatakan error
            else if(response.body().getError())
                callback.onLoadFailed(response.body().getMessage());

            else

            	// handling jika data pada respon koneksi kosong
                if(response.body().getData() == null)
                    callback.onDataNotAvailable();

                // handling jika respon koneksi berhasil (berisi data profile user)
                else
                    callback.onLoaded(response.body());
        }

        @Override
        public void onFailure(Call<GetUserResponse> call, Throwable t) {
            callback.onLoadFailed(t.getMessage());
        }
    });
}
```


***sampai pada step ini, tahap untuk persiapan koneksi server telah selesai. Berikutnya tahap untuk menampilkan data pada Activity.***


### 2. Main Task

Siapkan sebuah interface untuk menghubungkan View dan Presenter, misal beri nama dengan `ProfileContract.java`. 
Misalkan pada interface ini:

`View` hanya memiliki fitur untuk menampilkan data user.

`Presenter` hanya memiliki fitur untuk mengambil data dari server.

**Contract**
```java
public interface ProfileContract {
    interface View extends BaseView<Presenter>{
        void showData(GetUser user);
    }
    interface Presenter extends BasePresenter<View>{
        void getUserAndShowData(String userId);
    }
}
```

Lalu buat presenter dengan fitur mengambil data melalui koneksi ke server menggunakan method retrofit yang telah dibuat sebelumnya pada tahap Pre Task, method 

```java
getUser(final String auth, final String id, final GetCallbackListener callback)
```


pada Presenter realisasikan interface Presenter yang telah dibuat pada kontrak.

**Presenter**
```java
public class ProfilePresenter implements ProfileContract.Presenter {

    private ProfileContract.View rView;
    private RealmHelper rRealm;
    private RESTHelper rRest;

    public ProfilePresenter(){
        rRealm = new RealmHelper();
        rRest = new RESTHelper();
    }

    @Override
    public void getUserAndShowData(String userId) {
        rRest.getUser(rRealm.getUser().getAccessToken(), userId, new RESTHelper.GetCallbackListener() {
            @Override
            public void onLoaded(Object data) {

            	// data yang diterima masih berjenis Object, harus dilakukan casting
                GetUserResponse response = (GetUserResponse) data;

                // mengambil data melalui template respon
                GetUser user = response.getData();

                // menginvoke method showData yang ada pada View
                rView.showData(user);
            }

            @Override
            public void onDataNotAvailable() {

            }

            @Override
            public void onLoadFailed(String errorMessage) {

            }
        });
    }

    @Override
    public void bind(@NonNull ProfileContract.View view) {
        rView = view;
    }

    @Override
    public void unBind() {
        rView = null;
    }
}
```

***catatan*** *: token yang didapat saat login atau register disimpan pada realm, sehingga pada method getUserAndaShowData(String userId) diatas langsung menggunakan token user yang telah tersimpan sebelumnya pada realm*

setelah membuat kontrak dan presenter, berikutnya membuat `Activity` dan `View` (fragment) untuk menampilkan data yang diambil oleh `Presenter` melalui server.

`Fragment` akan ditaruh pada `Activity` sebagai kontainer fragment.

**Activity**
```java
public class ProfileActivity extends AppCompatActivity {

    private ProfileFragment fragment;
    private ProfilePresenter presenter;

    public static final String PROFILE_USER_ID_PASS = "PROFILE_USER_ID_PASS";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_profile);

        // 1. instansiasi fragment dan presenter
        fragment = ProfileFragment.newInstance("", getIntent().getStringExtra(PROFILE_USER_ID_PASS));
        presenter = new ProfilePresenter();

        // 2. set presenter pada fragment
        fragment.setPresenter(presenter);

        // 3. bind fragment pada presenter
        presenter.bind(fragment);

        // 4. taruh fragment pada activity
        ActivityHelper.replaceFragmentOnActivity(getSupportFragmentManager(),
                fragment, R.id.end_fragment_profile);
    }
}
```


pada View realisasikan interface View yang telah dibuat pada kontrak.

**View**
```java
public class ProfileFragment extends Fragment implements ProfileContract.View {

    private static final String ARG_PARAM2 = "param2";

    private String userId;
    private GetUser savedUser;

    ProfileContract.Presenter rPresenter;
    private ImageView imageCover;
    private ImageView imageProfile;
    private TextView textName;
    private TextView textAgeSexLocation;
    // ... atribut lainnya

    // pada android studio, fragment biasanya menggunakan kelas singleton
    public static ProfileFragment newInstance(String param1, String userId) {
        ProfileFragment fragment = new ProfileFragment();
        Bundle args = new Bundle();
        args.putString(ARG_PARAM2, userId);
        fragment.setArguments(args);
        return fragment;
    }

    // ... terdapat method-method lainnya

    // method ini akan di invoke oleh presenter saat presenter menerima respon berupa data profile dari server
    @Override
    public void showData(final GetUser user) {
        textName.setText(user.getName());
        textDescription.setText(user.getBio());

        // ... dst
    }

    @Override
	public void setPresenter(ProfileContract.Presenter presenter) {
        rPresenter = presenter;
    }
}

```


***sampai pada step ini, screen profile user untuk fitur menampilkan data saja sudah selesai.***


### 3. Post Task

Setelah mengimplementasi screen profile untuk fitur menampilkan profile user, tentunya ada fitur-fitur lain yang dibutuhkan, untuk melakukan pembahan fitur ulangi tahap pre task dan main task dengan menambah method dan interface.