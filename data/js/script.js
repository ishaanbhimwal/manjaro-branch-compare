fetch("datas.x86_64.json")
.then(function(response){
	return response.json();
})
.then(function(products){
	let placeholder = document.querySelector("#data-output");
	let out = "";
	for(let product of products){
		out += `
			<tr class="row">
				<td class="col">${product.name}</td>
				<td class="col">${product.stable}</td>
				<td class="col">${product.testing}</td>
				<td class="col">${product.unstable}</td>
				<td class="col">${product.repo}</td>
			</tr>
		`;
	}

	placeholder.innerHTML = out;
});

$(document).ready(function(){
	$("#tableSearch").on("keyup", function() {
	  var value = $(this).val().toLowerCase();
	  $("#data-output tr").filter(function() {
		$(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
	  });
	});
  });