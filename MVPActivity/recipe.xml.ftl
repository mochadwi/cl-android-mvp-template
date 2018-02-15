<?xml version="1.0"?>
<recipe>
    <merge from="root/AndroidManifest.xml.ftl"
             to="${escapeXmlAttribute(manifestOut)}/AndroidManifest.xml" />

    <merge from="root/res/values/manifest_strings.xml.ftl"
             to="${escapeXmlAttribute(resOut)}/values/strings.xml" />

    <#include "../common/recipe_simple.xml.ftl" />
    <open file="${escapeXmlAttribute(resOut)}/layout/${layoutName}.xml" />

    <instantiate from="root/src/app_package/SimpleActivity.java.ftl"
                   to="${escapeXmlAttribute(srcOut)}/${activityClass}.java" />

    <instantiate from="root/src/app_package/SimpleActivityContract.java.ftl"
                   to="${escapeXmlAttribute(srcOut)}/${activityClass}Contract.java" />

    <instantiate from="root/src/app_package/SimpleActivityFragment.java.ftl"
                   to="${escapeXmlAttribute(srcOut)}/${activityClass}Fragment.java" />

    <instantiate from="root/src/app_package/SimpleActivityPresenter.java.ftl"
                   to="${escapeXmlAttribute(srcOut)}/${activityClass}Presenter.java" />

    <open file="${escapeXmlAttribute(srcOut)}/${activityClass}.java" />
</recipe>