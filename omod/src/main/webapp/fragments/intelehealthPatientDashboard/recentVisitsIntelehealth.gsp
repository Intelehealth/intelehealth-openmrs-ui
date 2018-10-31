<div class="info-section">
    <div class="info-header">
        <i class="icon-calendar"></i>
        <h3>RECENT VISITS</h3>
    </div>
    <div class="info-body" ng-controller="recentVisitController">
	       <div ng-repeat="visit in recentVisits" class="clear">
		       	<a href='/openmrs/intelehealth/overview/patientSummary.page?patientId={{patientId}}&visitId={{visit.uuid}}' class="visit-link">{{visit.display | visitdate | date: 'dd.MMM.yyyy'}}</a>
		       	<div class="tag" ng-if="visit.visitStatus">{{visit.visitStatus}}</div>  
	       </div>
           <div class="tag1" id ="d"></div>
    </div>
    
</div>

<script>
var observation = []
var j = 0;
var a = window.location.href
var url = new URL(a);
var c = url.searchParams.get("patientId");
let url1 = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/obs?patient=" + c + "&concept=3edb0e09-9135-481e-b8f0-07a26fa9a5ce"
  \$.get(url1, function (data) {
      var length = data.results.length
      for (var l= 0; l<data.results.length; l++){
             var a = data.results[l].display;
            var obs = a.split('<b>');
      for (var i = 1; i < obs.length; i++){
            var obs1 = obs[i].split('<')
            observation[j] = obs1[0];
            j++;      
      }
      }
      \$('#d').html('<b> &nbsp &nbsp &nbsp &nbsp' + observation + '</b>');       
  })
  
</script>
