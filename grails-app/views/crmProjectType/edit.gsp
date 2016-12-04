<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmProjectType.label', default: 'Project Status')}"/>
    <title><g:message code="crmProjectType.edit.title" args="[entityName, crmProjectType]"/></title>
</head>

<body>

<crm:header title="crmProjectType.edit.title" args="[entityName, crmProjectType]"/>

<div class="row-fluid">
    <div class="span9">

        <g:hasErrors bean="${crmProjectType}">
            <crm:alert class="alert-error">
                <ul>
                    <g:eachError bean="${crmProjectType}" var="error">
                        <li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message
                                error="${error}"/></li>
                    </g:eachError>
                </ul>
            </crm:alert>
        </g:hasErrors>

        <g:form class="form-horizontal" action="edit" id="${crmProjectType?.id}">
            <g:hiddenField name="version" value="${crmProjectType?.version}"/>

            <div class="control-group">
                <label class="control-label">
                    <g:message code="crmProjectType.name.label"/>
                </label>

                <div class="controls">
                    <g:textField name="name" value="${crmProjectType.name}" autofocus=""/>
                </div>
            </div>

            <div class="control-group">
                <label class="control-label">
                    <g:message code="crmProjectType.description.label"/>
                </label>

                <div class="controls">
                    <g:textField name="description" value="${crmProjectType.description}" />
                </div>
            </div>

            <div class="control-group">
                <label class="control-label">
                    <g:message code="crmProjectType.param.label"/>
                </label>

                <div class="controls">
                    <g:textField name="param" value="${crmProjectType.param}" />
                </div>
            </div>

            <div class="control-group">
                <label class="control-label">
                    <g:message code="crmProjectType.icon.label"/>
                </label>

                <div class="controls">
                    <g:textField name="icon" value="${crmProjectType.icon}" />
                </div>
            </div>

            <div class="control-group">
                <label class="control-label">
                    <g:message code="crmProjectType.orderIndex.label"/>
                </label>

                <div class="controls">
                    <g:textField name="orderIndex" value="${crmProjectType.orderIndex}" />
                </div>
            </div>

            <div class="control-group">
                <label class="control-label">
                    <g:message code="crmProjectType.enabled.label"/>
                </label>

                <div class="controls">
                    <g:checkBox name="enabled" value="true" checked="${crmProjectType.enabled}"/>
                </div>
            </div>

            <div class="form-actions">
                <crm:button visual="warning" icon="icon-ok icon-white" label="crmProjectType.button.update.label"/>
                <crm:button action="delete" visual="danger" icon="icon-trash icon-white"
                            label="crmProjectType.button.delete.label"
                            confirm="crmProjectType.button.delete.confirm.message"
                            permission="crmProjectType:delete"/>
                                <crm:button type="link" action="list"
                            icon="icon-remove"
                            label="crmProjectType.button.cancel.label"/>
            </div>
        </g:form>
    </div>

    <div class="span3">
        <crm:submenu/>
    </div>
</div>
</body>
</html>
