window.alertModal = function(){
  SpiffyStoresApp.Modal.alert('Message for an alert window.');
}

window.confirmModal = function () {
  SpiffyStoresApp.Modal.confirm({
    title: "Are you sure you want to delete this?",
    message: "Do you want to delete your account? This can't be undone.",
    okButton: "Yes, delete it",
    cancelButton: "No, keep it",
    style: 'danger'
  }, function(result){
    if (result)
      SpiffyStoresApp.flashNotice("Delete has been confirmed.")
    else
      SpiffyStoresApp.flashNotice("Delete has been cancelled.")
  });
}

window.inputModal = function (prompt) {
  SpiffyStoresApp.Modal.input(prompt, function(result, data){
    if(result){
      SpiffyStoresApp.flashNotice("Received: \"" + data + "\"");
    }
    else{
      SpiffyStoresApp.flashError("Input cancelled.");
    }
  });
}

window.newModal = function(path, title){
  SpiffyStoresApp.Modal.open({
    src: path,
    title: title,
    height: 400,
    width: 'large',
    buttons: {
      primary: {
        label: "OK",
        message: 'modal_ok',
        callback: function(message){
          SpiffyStoresApp.Modal.close("ok");
        }
      },
      secondary: {
        label: "Cancel",
        callback: function(message){
          SpiffyStoresApp.Modal.close("cancel");
        }
      }
    },
  }, function(result){
    if (result == "ok")
      SpiffyStoresApp.flashNotice("'Ok' button pressed")
    else if (result == "cancel")
      SpiffyStoresApp.flashNotice("'Cancel' button pressed")
  });
}

window.newButtonModal = function(path, title){
  SpiffyStoresApp.Modal.open({
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
          callback: function(message){ SpiffyStoresApp.Modal.close("close"); }
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
      SpiffyStoresApp.flashNotice("'" + result + "' button pressed")
    else
      SpiffyStoresApp.flashNotice("No result returned")
  });
}
