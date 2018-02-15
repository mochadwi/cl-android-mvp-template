package ${packageName};

public class ${activityClass}Presenter implements ${activityClass}Contract.Presenter {

    private final ${activityClass}Contract.View mView;

    public ${activityClass}Presenter(${activityClass}Contract.View view) {
        this.mView = view;
    }

    @Override
    public void start() {
    }
}