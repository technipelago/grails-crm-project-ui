<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmProjectCategory.label', default: 'Project Status')}"/>
    <title><g:message code="crmProjectCategory.edit.title" args="[entityName, crmProjectCategory]"/></title>
</head>

<body>

<crm:header title="crmProjectCategory.edit.title" args="[entityName, crmProjectCategory]"/>

<div class="row-fluid">
    <div class="span9">

        <g:hasErrors bean="${crmProjectCategory}">
            <crm:alert class="alert-error">
                <ul>
                    <g:eachError bean="${crmProjectCategory}" var="error">
                        <li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message
                                error="${error}"/></li>
                    </g:eachError>
                </ul>
            </crm:alert>
        </g:hasErrors>

        <g:form class="form-horizontal" action="edit" id="${crmProjectCategory?.id}">
            <g:hiddenField name="version" value="${crmProjectCategory?.version}"/>

            <div class="control-group">
                <label class="control-label">
                    <g:message code="crmProjectCategory.name.label"/>
                </label>

                <div class="controls">
                    <g:textField name="name" value="${crmProjectCategory.name}" autofocus=""/>
                </div>
            </div>

            <div class="control-group">
                <label class="control-label">
                    <g:message code="crmProjectCategory.description.label"/>
                </label>

                <div class="controls">
                    <g:textField name="description" value="${crmProjectCategory.description}" />
                </div>
            </div>

            <div class="control-group">
                <label class="control-label">
                    <g:message code="crmProjectCategory.param.label"/>
                </label>

                <div class="controls">
                    <g:textField name="param" value="${crmProjectCategory.param}" />
                </div>
            </div>

            <div class="control-group">
                <label class="control-label">
                    <g:message code="crmProjectCategory.icon.label"/>
                </label>

                <div class="controls">
                    <g:textField name="icon" value="${crmProjectCategory.icon}" />
                </div>
            </div>

            <div class="control-group">
                <label class="control-label">
                    <g:message code="crmProjectCategory.orderIndex.label"/>
                </label>

                <div class="controls">
                    <g:textField name="orderIndex" value="${crmProjectCategory.orderIndex}" />
                </div>
            </div>

            <div class="control-group">
                <label class="control-label">
                    <g:message code="crmProjectCategory.enabled.label"/>
                </label>

                <div class="controls">
                    <g:checkBox name="enabled" value="true" checked="${crmProjectCategory.enabled}"/>
                </div>
            </div>

            <div class="form-actions">
                <crm:button visual="warning" icon="icon-ok icon-white" label="crmProjectCategory.button.update.label"/>
                <crm:button action="delete" visual="danger" icon="icon-trash icon-white"
                            label="crmProjectCategory.button.delete.label"
                            confirm="crmProjectCategory.button.delete.confirm.message"
                            permission="crmProjectCategory:delete"/>
                                <crm:button type="link" action="list"
                            icon="icon-remove"
                            label="crmProjectCategory.button.cancel.label"/>
            </div>
        </g:form>
    </div>

    <div class="span3">
        <crm:submenu/>
    </div>
</div>
</body>
</html>
