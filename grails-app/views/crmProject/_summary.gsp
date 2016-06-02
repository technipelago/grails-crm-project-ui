<%@ page import="grails.plugins.crm.core.DateUtils" defaultCodec="html" %>

<h4><g:message code="crmProject.summary.title"/></h4>

<p>

    <g:message code="crmProject.summary.name" args="${[bean.name]}"/>

    <g:if test="${bean.customer}">
        <g:message code="crmProject.summary.with.customer" args="${[bean.customer]}"/>
    </g:if>
    <g:else>
        <span class="label label-important"><g:message code="crmProject.summary.no.customer"/></span>
    </g:else>

    <g:message code="crmProject.summary.status"/>
    <g:fieldValue bean="${bean}" field="status"/>

    <g:if test="${bean.date2}">
        <g:message code="crmProject.summary.date2.label"/> <strong><g:formatDate date="${bean.date2}" type="date" style="long"/></strong>.
    </g:if>
    <g:else>
        <g:message code="crmProject.summary.date.blank"/>.
    </g:else>

    <g:if test="${bean.username}">
        <g:message code="crmProject.summary.username"/>
        <crm:user username="${bean.username}">${name}</crm:user>.
    </g:if>
    <g:else>
        <span class="label label-important"><g:message code="crmProject.summary.username.blank"/></span>
    </g:else>

</p>
