package ${packageName};

import ${packageName}.R;

import butterknife.BindView;
import butterknife.ButterKnife;

public class ${activityClass}Fragment extends Fragment implements ${activityClass}Contract.View {
    
    private ${activityClass}Contract.Presenter mPresenter;

    public static ${activityClass}Fragment newInstance() {
        return new ${activityClass}Fragment();
    }

    @Override
    public void onResume() {
        super.onResume();
        mPresenter.start();
    }

    @Override
    public void setPresenter(${activityClass}Contract.Presenter presenter) {
        this.mPresenter = presenter;
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.${activityClass}, container, false);
        ButterKnife.bind(this, view);
        return view;
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
    }

    @Override
    public void showProgress() {

    }

    @Override
    public void hideProgress() {

    }
}
