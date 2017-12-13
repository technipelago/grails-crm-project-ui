<g:form action="addRole">

    <input type="hidden" name="id" value="${crmProject.id}"/>

    <g:set var="entityName" value="${message(code: 'crmProjectRole.label', default: 'Role')}"/>

    <div class="modal-header">
        <a class="close" data-dismiss="modal">×</a>

        <h3><g:message code="crmProjectRole.create.title" default="Add role"
                       args="${[entityName, crmProject]}"/></h3>
    </div>

    <div id="add-role-body" class="modal-body" style="overflow: auto;">

        <div class="control-group">
            <label class="control-label"><g:message code="crmProjectRole.contact.label"/></label>
            <div class="controls">
                <input type="hidden" name="related" style="width: 75%;"/>
            </div>
        </div>

        <div class="control-group">
            <label class="control-label"><g:message code="crmProjectRole.type.label"/></label>

            <div class="controls">
                <g:select name="type" value="${bean.type?.param}" from="${roleTypes}" optionKey="param"
                          class="input-large"/>
            </div>
        </div>

        <div class="control-group">
            <label class="control-label"><g:message code="crmProjectRole.description.label"/></label>

            <div class="controls">
                <g:textArea name="description" value="${bean.description}" cols="70" rows="3" class="input-xxlarge"/>
            </div>
        </div>
    </div>

    <div class="modal-footer">
        <crm:button action="addRole" visual="success" icon="icon-ok icon-white"
                    label="crmProjectRole.button.save.label" default="Save"/>
        <a href="#" class="btn" data-dismiss="modal"><i class="icon-remove"></i> <g:message
                code="default.button.close.label" default="Close"/></a>
    </div>
</g:form>
