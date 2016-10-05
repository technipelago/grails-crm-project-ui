<%@ page import="grails.plugins.crm.project.CrmProject" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmProject.label', default: 'Project')}"/>
    <title><g:message code="crmProject.edit.title" args="[entityName, crmProject]"/></title>
    <r:require modules="datepicker,autocomplete"/>
    <r:script>
    $(document).ready(function() {
        <crm:datepicker selector=".date"/>

        // Parent project.
        $("input[name='parent.name']").autocomplete("${createLink(controller: 'crmProject', action: 'autocompleteProject')}", {
            remoteDataType: 'json',
            preventDefaultReturn: true,
            minChars: 1,
            selectFirst: true,
            useCache: false,
            filter: false,
            extraParams: { id: "${crmProject.id}"},
            onItemSelect: function(item) {
                $("input[name='parent.id']").val(item.data[0]);
            },
            onNoMatch: function() {
                $("input[name='parent.id']").val('');
            }
        });

        $('a[data-toggle="tab"]').on('shown', function (ev) {
            //ev.target // activated tab
            //ev.relatedTarget // previous tab
            $(ev.target.hash + ' input:visible:first').focus();
        });
    });
    </r:script>
</head>

<body>

<crm:header title="crmProject.edit.title" subtitle="${crmProject.customer?.encodeAsHTML()}"
            args="[entityName, crmProject]"/>

<g:hasErrors bean="${crmProject}">
    <crm:alert class="alert-error">
        <ul>
            <g:eachError bean="${crmProject}" var="error">
                <li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message
                        error="${error}"/></li>
            </g:eachError>
        </ul>
    </crm:alert>
</g:hasErrors>

<g:form action="edit">

    <g:hiddenField name="id" value="${crmProject?.id}"/>
    <g:hiddenField name="version" value="${crmProject?.version}"/>

    <div class="tabbable">
        <ul class="nav nav-tabs">
            <li class="active"><a href="#main" data-toggle="tab"><g:message
                    code="crmProject.tab.main.label"/></a>
            </li>
            <li><a href="#items" data-toggle="tab" accesskey="b"><g:message
                    code="crmProject.tab.budget.label"/>
                <crm:countIndicator count="${items.size()}"/></a>
            </li>
            <li><a href="#desc" data-toggle="tab" accesskey="d"><g:message
                    code="crmProject.tab.desc.label"/></a></li>

        </ul>

        <div class="tab-content">
            <div class="tab-pane active" id="main">
                <div class="row-fluid">

                    <div class="span3">
                        <div class="row-fluid">

                            <div class="control-group">
                                <label class="control-label">
                                    <g:message code="crmProject.name.label"/>
                                </label>

                                <div class="controls">
                                    <g:textField name="name" value="${crmProject.name}" class="span12" autofocus=""/>
                                </div>
                            </div>

                            <div class="control-group">
                                <label class="control-label">
                                    <g:message code="crmProject.number.label"/>
                                </label>

                                <div class="controls">
                                    <g:textField name="number" value="${crmProject.number}" class="span8"/>
                                </div>
                            </div>

                            <div class="control-group">
                                <label class="control-label">
                                    <g:message code="crmProject.parent.label"/>
                                </label>
                                <div class="controls">
                                    <input type="hidden" name="parent.id" value="${crmProject.parent?.id}"/>
                                    <g:textField name="parent.name" value="${crmProject.parent?.name}" class="span12" autocomplete="off"/>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="span3">
                        <div class="row-fluid">

                            <div class="control-group">
                                <label class="control-label">
                                    <g:message code="crmProject.status.label"/>
                                </label>

                                <div class="controls">
                                    <g:select name="status.id" from="${metadata.statusList}"
                                              optionKey="id"
                                              value="${crmProject.status?.id}" class="span12"/>
                                </div>
                            </div>

                            <div class="control-group">
                                <label class="control-label">
                                    <g:message code="crmProject.username.label"/>
                                </label>

                                <div class="controls">
                                    <g:select name="username" from="${metadata.userList}" optionKey="username"
                                              optionValue="name"
                                              noSelection="${['': '']}"
                                              value="${crmProject.username}" class="span12"/>
                                </div>
                            </div>

                        </div>
                    </div>

                    <div class="span3">
                        <div class="row-fluid">

                            <div class="control-group">
                                <label class="control-label">
                                    <g:message code="crmProject.date1.label"/>
                                </label>

                                <div class="controls">
                                    <div class="input-append date"
                                         data-date="${formatDate(type: 'date', date: crmProject.date1 ?: new Date())}">
                                        <g:textField name="date1" class="span11" size="10"
                                                     value="${formatDate(type: 'date', date: crmProject.date1)}"/><span
                                            class="add-on"><i class="icon-th"></i></span>
                                    </div>
                                </div>
                            </div>

                            <div class="control-group">
                                <label class="control-label">
                                    <g:message code="crmProject.date2.label"/>
                                </label>

                                <div class="controls">
                                    <div class="input-append date"
                                         data-date="${formatDate(type: 'date', date: crmProject.date2 ?: new Date())}">
                                        <g:textField name="date2" class="span11" size="10"
                                                     value="${formatDate(type: 'date', date: crmProject.date2)}"/><span
                                            class="add-on"><i class="icon-th"></i></span>
                                    </div>
                                </div>
                            </div>

                            <div class="control-group">
                                <label class="control-label">
                                    <g:message code="crmProject.date3.label"/>
                                </label>

                                <div class="controls">
                                    <div class="input-append date"
                                         data-date="${formatDate(type: 'date', date: crmProject.date3 ?: new Date())}">
                                        <g:textField name="date3" class="span11" size="10"
                                                     value="${formatDate(type: 'date', date: crmProject.date3)}"/><span
                                            class="add-on"><i class="icon-th"></i></span>
                                    </div>
                                </div>
                            </div>

                            <div class="control-group">
                                <label class="control-label">
                                    <g:message code="crmProject.date4.label"/>
                                </label>

                                <div class="controls">
                                    <div class="input-append date"
                                         data-date="${formatDate(type: 'date', date: crmProject.date4 ?: new Date())}">
                                        <g:textField name="date4" class="span11" size="10"
                                                     value="${formatDate(type: 'date', date: crmProject.date4)}"/><span
                                            class="add-on"><i class="icon-th"></i></span>
                                    </div>
                                </div>
                            </div>

                        </div>
                    </div>

                    <div class="span3">
                        <div class="row-fluid">
                            <div class="control-group">
                                <label class="control-label">
                                    <g:message code="crmProject.budget.label"/>
                                </label>

                                <div class="controls">

                                    <g:textField name="budget" readonly="${crmProject.budgetEditable ? false : true}"
                                                 value="${fieldValue(bean: crmProject, field: 'budget')}"
                                                 class="span8"/>
                                </div>
                            </div>

                            <div class="control-group">
                                <label class="control-label">
                                    <g:message code="crmProject.actual.label"/>
                                </label>

                                <div class="controls">

                                    <g:textField name="value" readonly="${crmProject.budgetEditable ? false : true}"
                                                 value="${fieldValue(bean: crmProject, field: 'actual')}"
                                                 class="span8"/>
                                </div>
                            </div>

                            <div class="control-group">
                                <label class="control-label">
                                    <g:message code="crmProject.currency.label"/>
                                </label>

                                <div class="controls">
                                    <g:select from="${metadata.currencyList}" name="currency"
                                              value="${crmProject.currency}" class="span8"/>
                                </div>
                            </div>
                        </div>
                    </div>

                </div>
            </div>

            <div class="tab-pane" id="items">
                <table class="table table-striped">
                    <thead>
                    <tr>
                        <th><g:message code="crmProjectItem.orderIndex.label" default="#"/></th>
                        <th><g:message code="crmProjectItem.name.label" default="Name"/></th>
                        <th><g:message code="crmProjectItem.budget.label" default="Comment"/></th>
                        <th><g:message code="crmProjectItem.actual.label" default="Budget"/></th>
                        <th><g:message code="crmProjectItem.vat.label" default="Actual"/></th>
                    </tr>
                    </thead>
                    <tbody>

                    <g:each in="${items}" var="item" status="i">
                        <tr>
                            <td style="width: 5%;">
                                <input type="hidden" name="items[${i}].id" value="${item.id}"/>

                                <g:textField name="items[${i}].orderIndex" value="${item.orderIndex}"
                                    style="width: 99%"/>
                            </td>
                            <td style="width: 45%;">
                                <g:textField name="items[${i}].name" value="${item.name}"
                                    style="width: 99%"/>
                            </td>
                            <td>
                                <g:textField name="items[${i}].budget" value="${fieldValue(bean: item, field: 'budget')}"
                                    style="width: 99%"/>
                            </td>
                            <td>
                                <g:textField name="items[${i}].actual" value="${fieldValue(bean: item, field: 'actual')}"
                                    style="width: 99%"/>
                            </td>
                            <td style="width: 10%;">
                                <g:select name="items[${i}].vat" from="${metadata.vatList}" value="${formatNumber(number:item.vat, minFractionDigits: 2)}"
                                          optionKey="${{formatNumber(number:it.value, minFractionDigits: 2)}}" optionValue="label" style="width:99%;"/>
                            </td>
                        </tr>
                    </g:each>

                    <g:each in="${(items.size())..(items.size()+2)}" var="i">
                        <tr>
                            <td style="width: 5%;">
                                <g:textField name="items[${i}].orderIndex" value="${items[i]?.orderIndex}"
                                    style="width: 99%"/>
                            </td>
                            <td style="width: 45%;">
                                <g:textField name="items[${i}].name" value="${items[i]?.name}"
                                    style="width: 99%"/>
                            </td>
                            <td>
                                <g:textField name="items[${i}].budget" value="${formatNumber(number: items[i]?.budget)}"
                                    style="width: 99%"/>
                            </td>
                            <td>
                                <g:textField name="items[${i}].actual" value="${formatNumber(number: items[i]?.actual)}"
                                    style="width: 99%"/>
                            </td>
                            <td style="width: 10%;">
                                <g:select name="items[${i}].vat" from="${metadata.vatList}" value="${formatNumber(number:items[i]?.vat, minFractionDigits: 2)}"
                                          optionKey="${{formatNumber(number:it.value, minFractionDigits: 2)}}" optionValue="label" style="width:99%;"/>
                            </td>
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>

            <div class="tab-pane" id="desc">
                <div class="control-group">
                    <label class="control-label">
                        <g:message code="crmProject.description.label"/>
                    </label>

                    <div class="controls">
                        <g:textArea name="description" rows="10" cols="80"
                                    value="${crmProject.description}" class="span11"/>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="form-actions">
        <crm:button visual="warning" icon="icon-ok icon-white" label="crmProject.button.update.label"/>
        <crm:button action="delete" visual="danger" icon="icon-trash icon-white"
                    label="crmProject.button.delete.label"
                    confirm="crmProject.button.delete.confirm.message" permission="crmProject:delete"/>
        <crm:button type="link" action="show" id="${crmProject.id}"
                    icon="icon-remove"
                    label="crmProject.button.cancel.label"/>
    </div>

</g:form>

</body>
</html>
