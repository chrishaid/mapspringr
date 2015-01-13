$(function(){
	//Handler for basic RPC
	$("#imputebutton").click(function(e){
		e.preventDefault()
		$(".springritfield").val("")
		var data = [];
		var subj = $('input[name="subjectfield"]:checked').val()
		$("tbody tr").each(function(i){
			data[i] = {
				Grade : parseFloat($(this).find(".gradefield").val()),
				TestRITScore : parseFloat($(this).find(".fallritfield").val()),
				Goal1RitScore : parseFloat($(this).find(".g1field").val()),
				Goal2RitScore : parseFloat($(this).find(".g2field").val()),
				Goal3RitScore : parseFloat($(this).find(".g3field").val()),
				Goal4RitScore : parseFloat($(this).find(".g4field").val()),
				PercentCorrect : parseFloat($(this).find(".pctcorrectfield").val()),
				TestDurationMinutes: parseFloat($(this).find(".durationfield").val())
			};
		});
		
		//RPC request to score data
		var req = ocpu.rpc("impute_spring", {input : data, subject : subj}, function(output){
			//repopulate the table
			$("tbody tr").each(function(i){
				$(this).find(".gradefield").val(output[i].Grade);				
				$(this).find(".fallritfield").val(output[i].TestRITScore);
				$(this).find(".g1field").val(output[i].Goal1RitScore);
				$(this).find(".g2field").val(output[i].Goal2RitScore);
				$(this).find(".g3field").val(output[i].Goal3RitScore);
				$(this).find(".g4field").val(output[i].Goal4RitScore);
				$(this).find(".pctcorrectfield").val(output[i].PercentCorrect);
				$(this).find(".durationfield").val(output[i].TestDurationMinutes);
				$(this).find(".springritfield").val(output[i].predict_RIT);
			});
		}).fail(function(){
			alert(req.responseText);
		});
	});

	//CSV file scoring
	$("#csvfile").on("change", function loadfile(e){
		if(!$("#csvfile").val()) return;
		$("#outputcsv").addClass("hide").attr("href", "");
		$(".spinner").show()
		var req = ocpu.call("impute_spring", {
			input : $("#csvfile")[0].files[0]
			subject : subj
		}, function(tmp){
			$("#outputcsv").removeClass("hide").attr("href", tmp.getLoc() + "R/.val/csv")
		}).fail(function(){
			alert(req.responseText)
		}).always(function(){
			$(".spinner").hide()
		});
	});

	//update the example curl line with the current server
	$("#curlcode").text(
		$("#curlcode").text().replace(
			"https://public.opencpu.org/ocpu/github/chrishaid/mapspringr/R/impute_spring/json", 
			window.location.href.match(".*/mapspringr/")[0] + "R/impute_spring/json"
		)
	);

	//this is just to create a table
	function addrow(){
		$("tbody").append('<tr> <td> <div class="form-group"> <input type="number" min="0" max="8" class="form-control gradefield" placeholder="Grade"> </div> </td> '
							 + '<td> <div class="form-group"> <input type ="number" min="100" max="275" class="form-control fallritfield" placeholder="Fall RIT"> </div> </td> '
							 + '<td> <div class="form-group"> <input type ="number" min="100" max="275" class="form-control g1field" placeholder="Goal 1 RIT"> </div> </td> '
							 + '<td> <div class="form-group"> <input type ="number" min="100" max="275" class="form-control g2field" placeholder="Goal 2 RIT"> </div> </td> '
							 + '<td> <div class="form-group"> <input type ="number" min="100" max="275" class="form-control g3field" placeholder="Goal 3 RIT"> </div> </td> '
							 + '<td> <div class="form-group"> <input type ="number" min="100" max="275" class="form-control g4field" placeholder="Goal 4 RIT"> </div> </td> '
							 + '<td> <div class="form-group"> <input type ="number" min="0" max="100" class="form-control pctcorrectfield" placeholder="% Correct"> </div> </td> '
							 + '<td> <div class="form-group"> <input type ="number" min="1" max="300" class="form-control durationfield" placeholder="Duration"> </div> </td> '
							 + '<td> <div class="form-group"> <input disabled="disabled" class="disabled form-control springritfield"> </div> </td> </tr>');
	}

	for(var i = 0; i < 5; i++){
		addrow();
	}
});