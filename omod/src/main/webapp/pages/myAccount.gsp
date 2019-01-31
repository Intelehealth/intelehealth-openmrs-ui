<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeCss("intelehealth", "flaticon/font/flaticon.css")
    ui.includeJavascript("intelehealth", "constants.js")
    ui.includeCss("intelehealth", "overview/youthness.css")
    ui.includeCss("intelehealth", "overview/arty.css")
    ui.includeCss("intelehealth", "overview/asem.css")
    ui.includeJavascript("intelehealth", "angularJS/angular.min.js")
    ui.includeJavascript("intelehealth", "angularJS/angular-sanitize.min.js")
    ui.includeJavascript("intelehealth", "angularJS/angular-animate.min.js")
    ui.includeJavascript("intelehealth", "EncounterService/encounter.module.js")
    ui.includeJavascript("intelehealth", "EncounterService/encounter.service.js")
%>
<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/referenceapplication/home.page' },
        { label: "${ ui.message("intelehealth.app.myAccount.label")}"}
    ];
</script>

<div ng-app="myApp">
<div ng-controller = "AccountController">
    <div>
    Enter text: <input type="text" ng-model="myText">
    </div>
<br>

<h3> Please choose your signature style: </h3>
<br>
    <div>
    <input type="radio" name="font" id="1" value="1"><span style="font-size:55px; font-family:Youthness"> {{myText}}</span>
    </div>
    <br>
    <div>
    <input type="radio" name="font" id="2" value="2"><span style="font-size:55px; font-family:Asem"> {{myText}}</span>
    </div> 
    <br>
    <div>
    <input type="radio" name="font" id="3" value="3"><span style="font-size:100px; font-family:Arty"> {{myText}}</span>
    </div>
    <br>
    <div>
    <button ng-click="signature()">Select</button>
    </div>
<br>
    <h2>{{status}}</h2>
</div>
</div>


<script>
var app = angular.module("myApp", ['ngSanitize', 'EncounterModule']);
app.controller('AccountController', function(\$scope, \$http, EncounterFactory) {
    \$scope.myText="Enter your Text"
    \$scope.signature = function() {
        var value = false;
       if (document.getElementById('1').checked) {
            insert(\$scope.myText, "Youthness")
        }
        else if(document.getElementById('2').checked){
            insert(\$scope.myText, "Asem")
        }
        else if(document.getElementById('3').checked){
            insert(\$scope.myText, "Arty")
        }
    }

    function insert (text, font) {
        var promiseuuid = EncounterFactory.postEncounter().then(function(response){
                return response;
            });
        promiseuuid.then(function(x){
        \$scope.uuid = x;
        var url = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/provider?user=" + \$scope.uuid;
        \$http.get(url).then(function(response){
            var providerUUID = response.data.results[0].uuid
            var url1 = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/provider/" + providerUUID + "/attribute";
            \$http.get(url1).then(function(response){
                if(response.data.results.length != 0){
                    \$scope.status = "Signature already exist!!";
                }else{
                var url2 = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/provider/" + providerUUID + "/attribute";
                var json = {
                    "attributeType": window.constantConfigObj.textOfSign,
                    "value": text
                    };
                \$http.post(url2, JSON.stringify(json)).then(function(response){
                    })
                var url3 = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/provider/"+ providerUUID +"/attribute";
                var json = {
                    "attributeType": window.constantConfigObj.fontOfSign,
                    "value": font
                    };
                \$http.post(url3, JSON.stringify(json)).then(function(response){
                    \$scope.status = "Success";
                    })
                }
            })
        })
        })
    };
});
</script>