package ${packageName};

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;

import android.content.Context;
import ${superClassFqcn};
import android.os.Bundle;
<#if includeCppSupport!false>
import android.widget.TextView;
</#if>

public class ${activityClass}Activity extends ${superClass} {

    private ${activityClass}Contract.Presenter mPresenter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.${layoutName});

        ${activityClass}Fragment view = (${activityClass}Fragment) getSupportFragmentManager()
                .findFragmentById(R.id.layoutFragment);

        if (view == null) {
            view = ${activityClass}Fragment.newInstance();

            ActivityUtils.addFragmentToActivity(getSupportFragmentManager(),
                    view, R.id.layoutFragment);
        }

        mPresenter = new ${activityClass}Presenter(view);
<#include "../../../../common/jni_code_usage.java.ftl">
    }
<#include "../../../../common/jni_code_snippet.java.ftl">
}