<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmProjectStatus.label', default: 'Project Status')}"/>
    <title><g:message code="crmProjectStatus.edit.title" args="[entityName, crmProjectStatus]"/></title>
</head>

<body>

<crm:header title="crmProjectStatus.edit.title" args="[entityName, crmProjectStatus]"/>

<div class="row-fluid">
    <div class="span9">

        <g:hasErrors bean="${crmProjectStatus}">
            <crm:alert class="alert-error">
                <ul>
                    <g:eachError bean="${crmProjectStatus}" var="error">
                        <li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message
                                error="${error}"/></li>
                    </g:eachError>
                </ul>
            </crm:alert>
        </g:hasErrors>

        <g:form class="form-horizontal" action="edit" id="${crmProjectStatus?.id}">
            <g:hiddenField name="version" value="${crmProjectStatus?.version}"/>

            <div class="control-group">
                <label class="control-label">
                    <g:message code="crmProjectStatus.name.label"/>
                </label>

                <div class="controls">
                    <g:textField name="name" value="${crmProjectStatus.name}" autofocus=""/>
                </div>
            </div>

            <div class="control-group">
                <label class="control-label">
                    <g:message code="crmProjectStatus.description.label"/>
                </label>

                <div class="controls">
                    <g:textField name="description" value="${crmProjectStatus.description}" />
                </div>
            </div>

            <div class="control-group">
                <label class="control-label">
                    <g:message code="crmProjectStatus.param.label"/>
                </label>

                <div class="controls">
                    <g:textField name="param" value="${crmProjectStatus.param}" />
                </div>
            </div>

            <div class="control-group">
                <label class="control-label">
                    <g:message code="crmProjectStatus.icon.label"/>
                </label>

                <div class="controls">
                    <g:textField name="icon" value="${crmProjectStatus.icon}" />
                </div>
            </div>

            <div class="control-group">
                <label class="control-label">
                    <g:message code="crmProjectStatus.orderIndex.label"/>
                </label>

                <div class="controls">
                    <g:textField name="orderIndex" value="${crmProjectStatus.orderIndex}" />
                </div>
            </div>

            <div class="control-group">
                <label class="control-label">
                    <g:message code="crmProjectStatus.enabled.label"/>
                </label>

                <div class="controls">
                    <g:checkBox name="enabled" value="true" checked="${crmProjectStatus.enabled}"/>
                </div>
            </div>

            <div class="form-actions">
                <crm:button visual="warning" icon="icon-ok icon-white" label="crmProjectStatus.button.update.label"/>
                <crm:button action="delete" visual="danger" icon="icon-trash icon-white"
                            label="crmProjectStatus.button.delete.label"
                            confirm="crmProjectStatus.button.delete.confirm.message"
                            permission="crmProjectStatus:delete"/>
                                <crm:button type="link" action="list"
                            icon="icon-remove"
                            label="crmProjectStatus.button.cancel.label"/>
            </div>
        </g:form>
    </div>

    <div class="span3">
        <crm:submenu/>
    </div>
</div>
</body>
</html>
