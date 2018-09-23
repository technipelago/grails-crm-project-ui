<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmProject.label', default: 'Project')}"/>
    <title><g:message code="crmProject.list.title" args="[entityName]"/></title>
</head>

<body>

<crm:header title="crmProject.list.title" subtitle="crmProject.totalCount.label"
            args="[entityName, crmProjectTotal]"/>

<table class="table table-striped">
    <thead>
    <tr>
        <g:sortableColumn property="number"
                          title="${message(code: 'crmProject.number.label', default: '#')}"/>
        <g:sortableColumn property="name"
                          title="${message(code: 'crmProject.name.label', default: 'Deal')}"/>
        <g:sortableColumn property="ref"
                                  title="${message(code: 'crmProject.ref.label', default: 'Reference')}"/>
        <g:sortableColumn property="customer.name"
                                  title="${message(code: 'crmProject.customer.label', default: 'Customer')}"/>
        <g:sortableColumn property="type.name"
                          title="${message(code: 'crmProject.type.label', default: 'Type')}"/>
        <g:sortableColumn property="category.name"
                          title="${message(code: 'crmProject.category.label', default: 'Category')}"/>
        <g:sortableColumn property="status.name"
                          title="${message(code: 'crmProject.status.label', default: 'Status')}"/>
        <g:sortableColumn property="date2"
                          title="${message(code: 'crmProject.date2.label', default: 'Order Date')}"/>
        <g:sortableColumn property="budget" class="money"
                          title="${message(code: 'crmProject.budget.label', default: 'Budget')}"/>
        <g:sortableColumn property="actual" class="money"
                          title="${message(code: 'crmProject.actual.label', default: 'Actual')}"/>
    </tr>
    </thead>
    <tbody>
    <g:each in="${crmProjectList}" var="crmProject">
        <tr>

            <td>
                <select:link action="show" id="${crmProject.id}" selection="${selection}">
                    ${fieldValue(bean: crmProject, field: "number")}
                </select:link>
            </td>

            <td>
                <select:link action="show" id="${crmProject.id}" selection="${selection}">
                    ${fieldValue(bean: crmProject, field: "name")}
                </select:link>
            </td>

            <td>
                <select:link action="show" id="${crmProject.id}" selection="${selection}">
                    ${crmProject.reference ?: crmProject.parent?.reference}
                </select:link>
            </td>

            <td>
                <select:link action="show" id="${crmProject.id}" selection="${selection}">
                    ${fieldValue(bean: crmProject, field: "customer")}
                </select:link>
            </td>

            <td>
                ${fieldValue(bean: crmProject, field: "type")}
            </td>

            <td>
                ${fieldValue(bean: crmProject, field: "category")}
            </td>

            <td>
                ${fieldValue(bean: crmProject, field: "status")}
            </td>

            <td class="nowrap">
                <g:formatDate type="date" date="${crmProject.date2}"/>
            </td>

            <td class="money nowrap">
                <g:formatNumber number="${crmProject.budget}" maxFractionDigits="0"
                                type="currency" currencyCode="${crmProject.currency ?: defaultCurrency}"/>
            </td>

            <td class="money nowrap ${crmProject.diff < 0 ? 'negative' : 'positive'}">
                <g:formatNumber number="${crmProject.actual}" maxFractionDigits="0"
                                type="currency" currencyCode="${crmProject.currency ?: defaultCurrency}"/>
            </td>
        </tr>
    </g:each>
    </tbody>
</table>

<crm:paginate total="${crmProjectTotal}"/>

<g:form class="form-actions btn-toolbar">
    <input type="hidden" name="offset" value="${params.offset ?: ''}"/>
    <input type="hidden" name="max" value="${params.max ?: ''}"/>
    <input type="hidden" name="sort" value="${params.sort ?: ''}"/>
    <input type="hidden" name="order" value="${params.order ?: ''}"/>

    <g:each in="${selection.selectionMap}" var="entry">
        <input type="hidden" name="${entry.key}" value="${entry.value}"/>
    </g:each>

    <crm:selectionMenu visual="primary"/>

    <g:if test="${crmProjectTotal}">
        <select:link action="export" accesskey="p" selection="${selection}" class="btn btn-info">
            <i class="icon-print icon-white"></i>
            <g:message code="crmProject.button.export.label" default="Print/Export"/>
        </select:link>
    </g:if>

    <crm:button type="link" group="true" action="create" visual="success" icon="icon-file icon-white"
                label="crmProject.button.create.label" permission="crmProject:create"/>
</g:form>

</body>
</html>
