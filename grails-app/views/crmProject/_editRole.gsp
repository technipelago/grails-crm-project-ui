<g:form action="editRole">

    <input type="hidden" name="id" value="${crmProject.id}"/>
    <input type="hidden" name="r" value="${bean.id}"/>
    <input type="hidden" name="version" value="${bean.version}"/>

    <g:set var="entityName" value="${message(code: 'crmProjectRole.label', default: 'Role')}"/>

    <div class="modal-header">
        <a class="close" data-dismiss="modal">×</a>

        <h3><g:message code="crmProjectRole.edit.title" default="Edit role" args="${[entityName, bean]}"/></h3>
    </div>

    <div id="add-role-body" class="modal-body" style="overflow: auto;">

        <div class="control-group">
            <label class="control-label"><g:message code="crmProjectRole.contact.label"/></label>
            <div class="controls">
                <input type="text" name="related" value="${bean.contact}" readonly="readonly" style="width: 75%;"/>
            </div>
        </div>

        <div class="control-group">
            <label class="control-label"><g:message code="crmProjectRole.type.label"/></label>

            <div class="controls">
                <g:select name="type.id" value="${bean.type.id}" from="${roleTypes}" optionKey="id"
                          class="input-large"/>
            </div>
        </div>

        <div class="control-group">
            <label class="control-label"><g:message code="crmProjectRole.description.label"/></label>

            <div class="controls">
                <g:textArea name="description" value="${bean.description}" cols="70" rows="3" class="input-xlarge"/>
            </div>
        </div>
    </div>

    <div class="modal-footer">
        <crm:button action="editRole" visual="success" icon="icon-ok icon-white"
                    label="crmProjectRole.button.save.label" default="Save"/>
        <crm:button action="deleteRole" visual="danger" icon="icon-trash icon-white"
                            label="crmProjectRole.button.delete.label" default="Delete"
        confirm="crmProjectRole.button.delete.confirm.message"/>
        <a href="#" class="btn" data-dismiss="modal"><i class="icon-remove"></i> <g:message
                code="default.button.close.label" default="Close"/></a>
    </div>
</g:form>
