({
  updateTotal: function (cmp) {
    let contacts = cmp.get("v.contacts");
    let totalContacts = 0;
    contacts.forEach(function (contact) {
       totalContacts++
    });
    cmp.set("v.totalContacts", totalContacts);
  },

  getMailingCountryPicklist: function (component) {
    var _this = this;
    var action = component.get("c.getMailingCountry");
    action.setParams({
      "fieldAPI": "MailingCountryCode"
    });
    action.setCallback(this, function (response) {
      var list = response.getReturnValue();
      component.set("v.MailingCountryPicklist", list);
    })
    $A.enqueueAction(action);
  },

  getJobRolePicklist: function (component) {
    var _this = this;
    var action = component.get("c.getMailingCountry");
    action.setParams({
      "fieldAPI": "Job_Role__c"
    });
    action.setCallback(this, function (response) {
      var list = response.getReturnValue();
      _this.removeA(list, "Other");
      list.unshift("Other");
      component.set("v.JobRolePicklist", list);
    })
    $A.enqueueAction(action);
  },

  removeA: function (arr) {
    var what, a = arguments, L = a.length, ax;
    while (L > 1 && arr.length) {
      what = a[--L];
      while ((ax = arr.indexOf(what)) !== -1) {
        arr.splice(ax, 1);
      }
    }
    return arr;
  },

    createClickToDialParamsJson : function (component, helper) {
        var paramsClickToDial = { "recordId" : component.get("v.recordId") };
        helper.performActionAsPromise(component, helper, "c.getPureCloudClickToDialParams", paramsClickToDial).then(
            function (response) {
                if (response) component.set("v.clickToDialParams", response);
                var paramsContacts = { "accountId" : component.get("v.recordId") };
                return helper.performActionAsPromise(component, helper, "c.getContactsFromAccountId", paramsContacts);
            }
        ).then(
            function (response) {
                component.set("v.contacts", response);
                helper.updateTotal(component);
            }
        ).catch(
            function(errResponse) {
                console.log(errResponse);
            }
        );
    },

    performActionAsPromise : function(component, helper, methodName, params) {
        return new Promise(function(resolve, reject) {
            helper.performAction(component, helper, methodName, params, function(isSuccess, response) {
                if (isSuccess) {
                    resolve(response);
                } else {
                    reject(response);
                }
            });
        });
    },

    performAction : function (component, helper, methodName, params, callback) {
        var action = component.get(methodName);
        action.setParams(params);
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
                callback(true, response.getReturnValue());
            } else {
                callback(false, response.getError());
            }
        });

        $A.enqueueAction(action);
    }
})