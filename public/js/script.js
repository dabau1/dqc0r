timeout = 0;
interval_default = 1;
interval = interval_default; // sekunden

function set_interval(x) { 
    if (x == 0) {
        interval = interval_default; 
    }
    else {
        interval = x * 60; 
    }
}

function start_timeout() { 
    if (interval > 0 && interval < 16 * 60) 
        timeout = setTimeout(refresh, interval * 1000); 
}

function cancel_timeout() { 
    if (interval > 0 && interval < 16 * 60) 
        clearTimeout(timeout); 
}

function disable_chat() {
    cancel_timeout();
    $('#refresh_button').attr('disabled', 'disabled');
}

function enable_chat() {
    if (interval > 1) $('#refresh_button').removeAttr('disabled');
    start_timeout();
}

function update(data) {

    // Chat messages
    $.map(data["msgs"], function(val, i) {
        var str = '';
        var classstr = new Array();
        if (val[6] == 0)
            str += '&nbsp;<span class="nick">'+val[1]+':</span>';
        if (val[6] == 3) {
            if ( val[7] == 1 ) {
                str += '&nbsp;<span class="nick">'+val[1]+' (an '+val[5]+'):</span>';
            }
            else {
                str += '&nbsp;<span class="nick">'+val[1]+' (privat):</span>';
                classstr.push('PrivateMsg');
            }
        }
        str += ' '+val[2];
        if (val[7] == 1) classstr.push('own_msg');
        if (val[8] == 1) classstr.push('MentionedMsg');
        if ((val[6] >= 10) && (val[6] <= 12)){
            if (val[6] == 10) classstr.push('Online');
            if (val[6] == 11) classstr.push('Busy');
            if (val[6] == 12) classstr.push('Away');
        }
        if ((val[6] >= 10 && val[6] <= 12) || (val[6] == 1))
            classstr.push('StatusMsg');
        if (classstr) str = '<span class="'+classstr.join(' ')+'">'+str+'</span>';
        str = '<p><span class="timestamp">'+val[3]+'</span>'+str+'</p>';
        $('#chatbox').append(str);
        $("#chatbox").each( function(){
            var scrollHeight = Math.max(this.scrollHeight, this.clientHeight);
            this.scrollTop = scrollHeight - this.clientHeight;
        });
    });

    // Buddy List
    $('#buddylist').empty();
    $.map(data["buddies"], function(val, i) {
        var namestr = val[0];
        if (val[5] == 1) {
            namestr = '&raquo; '+namestr;
            set_interval(val[1]);
            $('#refresh_interval').val(val[1]);
            if ( val[1] > 0 ) {
                $('#refresh_button').removeAttr('disabled', '');
            }
            else {
                $('#refresh_button').attr('disabled', 'disabled');
            }
            if (val[2] != 'Online' )
                $('#status').val(val[2].toLowerCase());
        }
        var classstr = new Array(val[2]);
        if ( val[1] != "0" ) {
            classstr.push('Refresh');
            if ( val[1] < 16 ) {
                if (val[5] == 1) {
                    namestr += ' (' + val[1] + ')';
                }
                else {
                    namestr += ' (' + val[3] + ')';
                }
            }
            else {
                namestr += ' (aus)';
            }
        }
        $('#buddylist').append('<p class="'+classstr.join(' ')+'">'+namestr+'</p>');
    });

    // Notes
    $('#sidepane').empty();
    $.map(data["notes"], function(val, i) {
        var str = '<p class="note">';
        if (val[4] == 1)
            str += '<button class="delete" onClick="del_note('+val[3]+')">x</button>';
        str += val[0]+' <b>'+val[1]+'</b>: '+val[2]+'</p>';
        $('#sidepane').append(str);
    });
    enable_chat();
}

function refresh(data) {
    disable_chat();
    if ( data ) {
        $.getJSON(urlbase+'/refresh', data, update);
    }
    else {
        $.getJSON(urlbase+'/refresh', update);
    }
}

function ajax_send(msg) {
    disable_chat();
    $.post( urlbase+'/msg', msg, update)
     .error(function(a,b,c){alert(c)});
}

function send() {
    var msg = $('#msg').val();
    if ( msg ) {
        $('#msg').val('');
        ajax_send({ "msg": msg });
    }
}

function send_on_enter(event) {
    if (!$('#sendonenter').attr('checked')) {
        if ( event.keyCode == 13 ) {
            send();
        }
    }
}

function set_status(val) { ajax_send({"msg": '/'+val}) }
function del_note(val) { ajax_send({"msg": '/del_news '+val}) }

function set_refresh(val) {
    disable_chat();
    set_interval(val);
    ajax_send({"msg": '/set_refresh '+val});
}

function bbcode(val) {
    $('#msg').val('['+val+']'+$('#msg').val()+'[/'+val+']');
}

