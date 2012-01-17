sub action_adminmenu {
    print &GetHeader("", T('Admin Menu'), "");
    return if (!&UserIsAdminOrError());

    print
        "<p>".&ScriptLink("action=editlinks",T('Editing/Deleting page titles:')).
        "<p>".&ScriptLink("action=editbanned",T('Editing Banned list')).
        "<p>".&ScriptLink("action=editbannedtext",T('Editing Banned text')).
        "<p>".&ScriptLink("action=maintain",T('Maintenance on all pages')).
        "<p>".&ScriptLink("action=editlock&set=1",T('Lock Site')).
        " | ".&ScriptLink("action=editlock&set=0",T('Unlock Site')).
        "<p>".&ScriptLink("action=unlock",T('Removing edit lock')).
        "<p>".&ScriptLink("action=replacetext",T('Replace strings in all pages')).
        "\n";

    print &GetCommonFooter();
}

1;
