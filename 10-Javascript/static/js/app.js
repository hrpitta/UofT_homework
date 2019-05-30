// from data.js
var tableData = data;

// Get a reference to the table body
var tbody = d3.select("tbody");

// YOUR CODE HERE!

// Select the submit button
var submit = d3.select("#filter-btn");

submit.on("click", function() {

  // Prevent the page from refreshing
  d3.event.preventDefault();

  // Select the input element and get the raw HTML node
  var inputDate = d3.select("#datetime");
  var inputCity = d3.select("#city");
  var inputState = d3.select("#state");
  var inputCountry = d3.select("#country");
  var inputShape = d3.select("#shape");
 

  // Get the value property of the input element
  
  var inputValue = inputDate.property("value");
  //const date = new Date(`${month}-${day}-${year}`)
  //const isValidDate = (Boolean(+date) && date.getDate() == day)
  console.log(inputValue);
  //console.log(tableData);

  var filteredData = tableData.filter(table => table.datetime === inputValue);
  console.log(filteredData)
  
  if (filteredData.length >= 1) {
   d3.selectAll("td").remove();
   filteredData.forEach((ufoReport) => {
    var row = tbody.append("tr");
    Object.entries(ufoReport).forEach(([key, value]) => {
      var cell = row.append("td");
      cell.text(value);
    });
  });
  }
  else {
    d3.selectAll("td").remove();
    alert("No data for this search criteria!");
  }
});