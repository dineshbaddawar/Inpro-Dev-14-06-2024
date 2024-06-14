({
  doInit: function (component, event, helper) {
    var camp = component.get("c.Campaign");
    var campret;
    var campaignList = [];
    var campaignid;
    var campaignName;
    var temp = {};
    var eventid;

    // Time input set to noon
    component.set("v.inputTime", "12:00:00.000");

    camp.setCallback(this, function (response) {
      campret = response.getReturnValue();
      //console.log("campret",campret);
      for (var i = 0; i < campret.length; i++) {
        if (
          campret[i].Id.substring(0, 15) == component.get("v.CampaignIdFromUrl")
        ) {
          var temp = {
            Name: campret[i].Name,
            Id: campret[i].Id,
            checked: true
          };
          component.set("v.CampaignName", campret[i].Name);
          component.set("v.CampaignId", campret[i].Id);
        } else {
          var temp = {
            Name: campret[i].Name,
            Id: campret[i].Id,
            checked: false
          };
        }
        campaignList.push(temp);
      }
      //console.log('campaignList',campaignList);
      component.set("v.Namelist", campaignList);
    });
    $A.enqueueAction(camp);
  },
  onGroup: function (cmp, event) {
    var selected = event.target.value;
    var selected1 = event.target.id;
    cmp.set("v.CampaignName", selected);
    cmp.set("v.CampaignId", selected1);
    //console.log("selected"+selected);
  },
  AccountDetails: function (component, event, helper) {
    // var AccountId = component.get("v.AccountId");
    //console.log("AccountId", AccountId);
    const accountIdBlank = ( 
      component.get("v.AccountId") == "" || 
      component.get("v.AccountId") == null 
    );
    
    const locationBlank = (
      component.get("v.location") == "" ||
      component.get("v.location") == null
    );

    const campaignIdBlank = (
      component.get("v.CampaignId") == null
    );

    const dateBlank = (
      component.get("v.inputDate") === null
    );

    const timeBlank = (
      component.get("v.inputTime") === null
    );
    
    if (accountIdBlank && locationBlank) {
      component.set("v.errorMessage", "Please enter an Account or Location");
      component.set("v.errorMsg", true);
    } else if (!accountIdBlank && !locationBlank) {
      component.set("v.errorMessage", "Please select an Account or Location (but not both)");
      component.set("v.errorMsg", true);
    } else if (campaignIdBlank) {
      component.set("v.errorMessage", "Please choose a Course for the event");
      component.set("v.errorMsg", true);
    } else if (dateBlank) {
      component.set("v.errorMessage", "Please enter a date");
      component.set("v.errorMsg", true);
    } else if (timeBlank) {
      component.set("v.errorMessage", "Please enter a time");
      component.set("v.errorMsg", true);
    } else {
      helper.searchDuplicateEvents(component);
    }
  },
  closeModel: function (component, event, helper) {
    component.set("v.isOpen", false);
  },
  closeToast: function (component, event, helper) {
    component.set("v.errorMsg", false);
  },
  ConfirmedContinue: function (component, event, helper) {
    component.set("v.isOpen", false);
    helper.createEvent(component);
  },
  close: function (component, event, helper) {
    component.set("v.errorMsg", false);
  },
  itemSelected: function (component, event, helper) {
    helper.itemSelected(component, event, helper);
  },

  serverCall: function (component, event, helper) {
    helper.serverCall(component, event, helper);
  },

  clearSelection: function (component, event, helper) {
    helper.clearSelection(component, event, helper);
  },
  cancelW: function (component, event) {
    window.history.back();
  }
});