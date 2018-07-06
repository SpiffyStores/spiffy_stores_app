window.alertModal = function(){
  SpiffyApp.Modal.alert('Message for an alert window.');
}

window.confirmModal = function () {
  SpiffyApp.Modal.confirm({
    title: "Are you sure you want to delete this?",
    message: "Do you want to delete your account? This can't be undone.",
    okButton: "Yes, delete it",
    cancelButton: "No, keep it",
    style: 'danger'
  }, function(result){
    if (result)
      SpiffyApp.flashNotice("Delete has been confirmed.")
    else
      SpiffyApp.flashNotice("Delete has been cancelled.")
  });
}

window.inputModal = function (prompt) {
  SpiffyApp.Modal.input(prompt, function(result, data){
    if(result){
      SpiffyApp.flashNotice("Received: \"" + data + "\"");
    }
    else{
      SpiffyApp.flashError("Input cancelled.");
    }
  });
}

window.newModal = function(path, title){
  SpiffyApp.Modal.open({
    src: path,
    title: title,
    height: 400,
    width: 'large',
    buttons: {
      primary: {
        label: "OK",
        message: 'modal_ok',
        callback: function(message){
          SpiffyApp.Modal.close("ok");
        }
      },
      secondary: {
        label: "Cancel",
        callback: function(message){
          SpiffyApp.Modal.close("cancel");
        }
      }
    },
  }, function(result){
    if (result == "ok")
      SpiffyApp.flashNotice("'Ok' button pressed")
    else if (result == "cancel")
      SpiffyApp.flashNotice("'Cancel' button pressed")
  });
}

window.newButtonModal = function(path, title){
  SpiffyApp.Modal.open({
    src: path,
    title: title,
    height: 400,
    width: 'large',
    buttons: {
      primary: {
        label: "Yes",
        callback: function(){ alert("'Yes' button clicked"); }
      },
      secondary: [
        {
          label: "Close",
          callback: function(message){ SpiffyApp.Modal.close("close"); }
        },
        {
          label: "Normal",
          callback: function(){ alert("'Normal' button clicked"); }
        }
      ],
      tertiary: [
        {
          label: "Danger",
          style: "danger",
          callback: function(){ alert("'Danger' button clicked"); }
        },
        {
          label: "Disabled",
          style: "disabled"
        }
      ]
    },
  }, function(result){
    if (result)
      SpiffyApp.flashNotice("'" + result + "' button pressed")
    else
      SpiffyApp.flashNotice("No result returned")
  });
}
