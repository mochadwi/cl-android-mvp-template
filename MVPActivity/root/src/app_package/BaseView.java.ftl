<#--  <#if applicationPackage??>  -->
package ${mainPackageName};
<#--  </#if>  -->

import android.content.Context;

public interface BaseView<T> {
    void setPresenter(T presenter);
    Context getContext();
    void showProgress();
    void hideProgress();
}