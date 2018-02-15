package ${packageName};

import ${packageName}.BasePresenter;
import ${packageName}.BaseView;

public interface ${activityClass}Contract {
    interface View extends BaseView<Presenter> {
    }

    interface Presenter extends BasePresenter {
    }
}