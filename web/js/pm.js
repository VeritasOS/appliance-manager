function isChecked(checkboxes) {
    checked = false
    for (const action of checkboxes) {
        checked = document.getElementById(action).checked
        if (checked) {
            console.log("Action: ", action, "; ", "Checkbox ", checked);
            return true
        }
    }
    return false
}

function updateTextBoxVisibility(textboxID, show) {
    if (show) {
        document.getElementById(textboxID).style.display = "block";
    } else {
        document.getElementById(textboxID).style.display = "none";
    }
}

// TODO: Provide 'Set as default values' option to save entered values 
//  as default values, and load them when clicked on load my values.

function loadMyDefaultValues(checkedElement) {
    console.log("Check triggered by", checkedElement.id)
    input = [checkedElement.id]
    checked = isChecked(input)

    var default_values = {
        'download_url_input': "https://artifactory-appliance.engba.veritas.com:443/artifactory/archive/GA/nbfs/3.2/3.2-20240316224905/post_release_3.2-20240317003218/3.2-1/VRTSnbfs_app_update-3.2-20240316224905.x86_64.rpm",
        'cluster_input': "capetowncl02",
        'dr_cluster_input': "lagoscl02",
    }

    for (const key in default_values) {
        if (checked) {
            document.getElementById(key).value = default_values[key];
        } else {
            document.getElementById(key).value = ""
        }
    }
}

function updateForm(checkedElement) {
    console.log("Check triggered by", checkedElement.id)
    var input_for_actions = {
        // Developer mode actions
        'dev-build-header': [
            'developer-mode'
        ],
        'dev-code': [
            'developer-mode'
        ],
        'dev-build-nas': [
            'developer-mode'
        ],
        'dev-build-update': [
            'developer-mode'
        ],
        //  Build related
        'branch_name': [
            'build-nas',
            'code'
        ],
        'builder': [
            'build-nas',
            'build-rhel7-update',
            'code'
        ],

        // Customer actions
        'cluster': [
            'cluster-config',
            'replication',
            'upgrade',
            'upgrade-precheck',
            'upload'
        ],
        'download_url': [
            'download'
        ],
        'dr_cluster': [
            'replication'
        ],
    }

    enable_buttons = false
    for (const input in input_for_actions) {
        checked = isChecked(input_for_actions[input])
        updateTextBoxVisibility(input, checked)
        if (checked && input_for_actions[input] != 'developer-mode') {
            enable_buttons = true
        }
    }

    buttons_list = ['list-btn', 'run-btn']
    if (enable_buttons) {
        console.log("Enabling buttons...")
        for (const btn of buttons_list) {
            document.getElementById(btn).removeAttribute("disabled");
        }
    } else {
        console.log("Disabling buttons...")
        for (const btn of buttons_list) {
            document.getElementById(btn).disabled = "true";
        }
    }
}

function updateParameters(x) {
    console.log("Triggered by ", x.id)
    console.log("x.value:", x.value)
    document.getElementById('env').innerHTML = document.getElementById('env').innerHTML + '\n' + x.name + '=' + x.value

    var envDict = {}
    lines = document.getElementById('env').innerHTML.split('\n')
    for (const line of lines) {
        if (line == "") {
            continue
        }
        console.log("Line (", line.length, "): ", line)
        fields = line.split('=')
        key = fields[0]
        val = line.split('=').slice(1).join('=')
        envDict[key] = val
    }
    // New value should overwrite earlier value, so assign new value here...
    envDict[x.name] = x.value
    textarea_value = ""
    Object.keys(envDict).forEach(function (key) {
        textarea_value += key + '=' + envDict[key] + "\n";
    });
    document.getElementById('env').innerHTML = textarea_value
}

Split({
    columnGutters: [{
        track: 1,
        element: document.querySelector('.gutter-col-1'),
    }],
    rowGutters: [{
        track: 1,
        element: document.querySelector('.gutter-row-1'),
    }, {
        track: 3,
        element: document.querySelector('.gutter-row-3'),
    }]
})