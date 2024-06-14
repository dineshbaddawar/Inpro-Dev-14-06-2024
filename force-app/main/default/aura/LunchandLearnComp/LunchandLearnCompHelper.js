({
  createEvent: function (component) {
    var AccountId = component.get("v.AccountId");
    var location = component.get("v.location");
    var camp = component.get("c.createEvent");
    var campaignname = component.get("v.CampaignName");
    var campaignid = component.get("v.CampaignId");
    var dt = this.getDateAndTimeString(component);
    var eventid;

    camp.setParams({
      accid: AccountId,
      location: location,
      campaignname: campaignname,
      campaignid: campaignid,
      dateTimes: dt
    });

    camp.setCallback(this, function (response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        eventid = response.getReturnValue();
        component.set("v.EventId", eventid);
        var EventId2 = component.get("v.EventId");
        //
        if (typeof sforce != "undefined") sforce.one.navigateToSObject(eventid);
        else window.location = "/" + eventid;
      } else if (state === "INCOMPLETE") {
        component.set(
          "v.errorMessage",
          "Something went wrong please refresh the page and try again!"
        );
        component.set("v.errorMsg", true);
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
            component.set("v.errorMessage", errors[0].message);
            component.set("v.errorMsg", true);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(camp);
  },
  searchDuplicateEvents: function (component) {
    component.set("v.errorMsg", false);
    var campaignid = component.get("v.CampaignId");
    var accid = component.get("v.AccountId");
    var location = component.get("v.location");
    var comp = component.get("c.searchDuplicateEvents");
    var dt = this.getDateAndTimeString(component);
    comp.setParams({
      accid: accid,
      location: location,
      campaignid: campaignid,
      dateTimes: dt
    });
    var events;
    comp.setCallback(this, function (res) {
      var state = res.getState();
      if (state == "SUCCESS") {
        events = res.getReturnValue();

        if (events != null) {
          component.set("v.isOpen", true);
          component.set("v.OldEvt", events);
        } else {
          this.createEvent(component);
        }
      } else {
        const err = res.getError();
        const msg = err[0].message;
        alert(
          "Something went wrong please refresh the page and try again! \nError Message: " +
            msg
        );
      }
    });
    $A.enqueueAction(comp);
  },
  itemSelected: function (component, event, helper) {
    var target = event.target;
    var SelIndex = helper.getIndexFrmParent(
      target,
      helper,
      "data-selectedIndex"
    );
    console.log(SelIndex);
    if (SelIndex) {
      var serverResult = component.get("v.server_result");
      var selItem = serverResult[SelIndex];
      console.log(selItem);
      if (selItem.val) {
        component.set("v.AccountId", selItem.val);
        component.set("v.selItem", selItem);
        component.set("v.last_ServerResult", serverResult);
      }
      component.set("v.server_result", null);
    }
  },

  serverCall: function (component, event, helper) {
    var target = event.target;
    var searchText = target.value;
    var last_SearchText = component.get("v.last_SearchText");
    console.log("last_SearchText", last_SearchText);
    //Escape button pressed
    if (event.keyCode == 27 || !searchText.trim()) {
      helper.clearSelection(component, event, helper);
    } else if (searchText.trim() != last_SearchText) {
      //Save server call, if last text not changed

      //Search only when space character entere /\s+$/.test(searchText)

      var limit = component.get("v.limit");
      var action = component.get("c.searchDB");
      action.setStorable();
      action.setParams({
        lim: limit,
        searchText: searchText
      });
      action.setCallback(this, function (a) {
        this.handleResponse(a, component, helper);
      });

      component.set("v.last_SearchText", searchText.trim());
      console.log("Server call made");
      $A.enqueueAction(action);
    } else if (
      searchText &&
      last_SearchText &&
      searchText.trim() == last_SearchText.trim()
    ) {
      component.set("v.server_result", component.get("v.last_ServerResult"));
      console.log("Server call saved");
    }
  },
  handleResponse: function (res, component, helper) {
    if (res.getState() === "SUCCESS") {
      var retObj = JSON.parse(res.getReturnValue());
      if (retObj.length <= 0) {
        var noResult = JSON.parse('[{"text":"No Results Found"}]');
        component.set("v.server_result", noResult);
        component.set("v.last_ServerResult", noResult);
      } else {
        component.set("v.server_result", retObj);
        component.set("v.last_ServerResult", retObj);
      }
    } else if (res.getState() === "ERROR") {
      var errors = res.getError();
      if (errors) {
        if (errors[0] && errors[0].message) {
          alert(errors[0].message);
        }
      }
    }
  },
  getIndexFrmParent: function (target, helper, attributeToFind) {
    //User can click on any child element, so traverse till intended parent found
    var SelIndex = target.getAttribute(attributeToFind);
    while (!SelIndex) {
      target = target.parentNode;
      SelIndex = helper.getIndexFrmParent(target, helper, attributeToFind);
    }
    return SelIndex;
  },
  clearSelection: function (component, event, helper) {
    component.set("v.selItem", null);
    component.set("v.server_result", null);
    component.set("v.AccountId", null);
  },
  getDateAndTimeString: function (component) {
    var inDate = component.get("v.inputDate");
    var inTime = component.get("v.inputTime");
    var dt = inDate + 'T' + inTime + 'Z';
    return dt;
  }
});