<%
    ui.includeCss("intelehealth", "overview/youthness.css")
    ui.includeCss("intelehealth", "overview/arty.css")
    ui.includeCss("intelehealth", "overview/asem.css")
%>
<div id="sign" ng-controller = "SubmitController">
<br>
	<div class="info-body" ng-cloak>
    <br/>  
        <div align="center">
        <h4 ng-if="font == 'Arty'" style="font-size:85px; font-family:{{font}};">{{text}}</h4>
        <h4 ng-if="font != 'Arty'" style="font-size:35px; font-family:{{font}};">{{text}}</h4>
        <button class='confirm' ng-click="submit()">Sign and Submit</button>
        </div>
      <div align ="center">
      <br>
      <p>{{statuscode1}}</p>
      </div>
  </div>
</div>

<script>

var visitNoteEncounterUuid = "";
var path = window.location.search;
var i = path.indexOf("visitId=");
var visitId = path.substr(i + 8, path.length);
var isSeenPresent = false;

var app = angular.module('Submit', ['ngAnimate', 'ngResource', 'EncounterModule', 'ngSanitize',
  'recentVisit', 'ui.bootstrap','ui.carousel'])

app.controller('SubmitController', function(\$scope, \$http, recentVisitFactory, EncounterFactory, \$timeout) {
        \$scope.submit = function() {
         var patient = "${ patient.uuid }";
         var date2 = new Date();
         \$scope.isLoading = true;
         \$scope.visitEncounters = [];
         \$scope.visitObs = [];
         \$scope.visitNoteData = [];
         \$scope.visitStatus = false;
         recentVisitFactory.fetchVisitDetails(visitId).then(function(data) {
          \$scope.visitDetails = data.data;
          \$scope.visitEncounters = data.data.encounters;
          if(\$scope.visitEncounters.length !== 0) {
          angular.forEach(\$scope.visitEncounters, function(value, key){
            var encounter = value.display;
            if(encounter.match("Visit Complete") !== null) {
       //This stores the value of encounter we got from response into the encounterValue object in Scripts-> EncounterService
            EncounterFactory.encounterValue = value.uuid;
            isSeenPresent = true;
            alert("Visit Already Completed");
            }
          });
          }
          if (isSeenPresent == false || \$scope.visitEncounters.length == 0) {
            var promiseuuid = EncounterFactory.postEncounter().then(function(response){
              return response;
            });
            promiseuuid.then(function(x){
              \$scope.uuid = x;
              \$scope.uuid3;
              //GETing encounter provider value
              var url2 = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/provider?user=" + \$scope.uuid;
              \$http.get(url2).then(function(response){
                angular.forEach(response.data.results, function(v, k){
                  var uuid = v.uuid;
                  \$scope.providerUUID = uuid
                  var url1 = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/encounter";
                  var json = {
                          patient: patient,
                          encounterType: window.constantConfigObj.encounterTypeVisitComplete,
                          encounterProviders:[{
                          provider: uuid,
                          encounterRole: window.constantConfigObj.encounterRoleDoctor
                            }],
                          visit: visitId,
                          encounterDatetime: date2
                        };
                                           
\$http.post(url1, JSON.stringify(json)).then(function(response){
      \$scope.statuscode1 = "Visit Complete";
       // On success response store the response uuid into the encounter object
       //This stores the value of encounter we got from response into the encounterValue object in Scripts-> EncounterService
      EncounterFactory.encounterValue = response.data.uuid;
        }, function(response){
          \$scope.statuscode1 = "Failed to create Encounter";
          });

          
        });
    },function(response){
        console.log("Get user uuid Failed!");
      });
          });
        }
      }, function(error) {
    console.log(error);
    }); 

    var promiseuuid = EncounterFactory.postEncounter().then(function(response){
    return response;
    });
    promiseuuid.then(function(x){
    \$scope.uuid = x;
    //GETing encounter provider value
    var user = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/provider?user=" + \$scope.uuid;
    \$http.get(user).then(function(response){
    angular.forEach(response.data.results, function(v, k){
      var providerUUID = v.uuid;
      var signRequest = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/provider/" + providerUUID + "/attribute";
            \$http.get(signRequest).then(function(response){
                if(response.data.results.length != 0){
                  angular.forEach(response.data.results, (res) => {
                    var display = res.display;
                    if(display.match("Font of sign") !== null){
                      \$scope.font = res.value
                    }
                    if(display.match("Text of sign") !== null){
                      \$scope.text = res.value
                    }
                  })
                }else{
                  if (window.confirm('Your signature is not setup! If you click "Ok" you would be redirected . Cancel will load this website ')) 
                    {
                    window.location.href='/openmrs/intelehealth/myAccount.page?app=intelehealth.myAccount';
                    };
                }
            })
    })
    })
    })

  }
})
</script>