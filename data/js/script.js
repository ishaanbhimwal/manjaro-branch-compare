fetch("datas.x86_64.json")
    .then(function (response) {
        return response.json();
    })
    .then(function (products) {
        let placeholder = document.querySelector("#data-output");
        let out = "";
        for (let product of products) {
            out += `
			<tr class="row">
				<td class="col"><a href="https://software.manjaro.org/package/${product.name}">${product.name}</a></td>
				<td class="col">${product.stable}</td>
				<td class="col">${product.testing}</td>
				<td class="col">${product.unstable}</td>
				<td class="col">${product.repo}</td>
			</tr>
		`;
        }

        placeholder.innerHTML = out;
    });

function searchTable() {
    var input, filter, found, table, tr, td, i, j;
    input = document.getElementById("myInput");
    filter = input.value.toUpperCase();
    table = document.getElementById("data-output");
    tr = table.getElementsByTagName("tr");
    for (i = 0; i < tr.length; i++) {
        td = tr[i].getElementsByTagName("td");
        for (j = 0; j < td.length; j++) {
            if (td[j].innerHTML.toUpperCase().indexOf(filter) > -1) {
                found = true;
            }
        }
        if (found) {
            tr[i].style.display = "";
            found = false;
        } else {
            tr[i].style.display = "none";
        }
    }
};

const params = new Proxy(new URLSearchParams(window.location.search), {
    get: (searchParams, prop) => searchParams.get(prop),
});

function sleep(time) {
    return new Promise((resolve) => setTimeout(resolve, time));
};

if (params.query != null) {
    document.getElementById("myInput").value = params.query;
    sleep(2000).then(() => {
        searchTable();
    });
};
