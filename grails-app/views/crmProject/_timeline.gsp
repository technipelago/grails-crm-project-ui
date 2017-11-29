<r:script type="text/javascript">
  var timeline;

  google.load("visualization", "1");

  // Set callback to run when API is loaded
  google.setOnLoadCallback(drawVisualization);

  // Called when the Visualization API is loaded.
  function drawVisualization() {
    // Create and populate a data table.
    var data = new google.visualization.DataTable();
    data.addColumn('datetime', 'start');
    data.addColumn('datetime', 'end');
    data.addColumn('string', 'content');
    data.addColumn('string', 'group');
    data.addColumn('string', 'className');

    $.getJSON("${createLink(action: 'events', params: [id: bean.id])}", {cb: +new Date}, function(result) {
        $.each(result, function(index, model) {
           var start = model.start;
           var end = model.end;
           if(start) {
               start = new Date(Date.parse(start));
           } else {
               start = null;
           }
           if(end) {
               end = new Date(Date.parse(end));
           } else {
               end = null;
           }
           data.addRow([start, end, model.content, model.group, model.className]);
        });

        // specify options
        var options = {
          "locale": "sv",
          "width":  "100%",
          "height": "auto",
          "minHeight": 400,
          "style": "box",
          "zoomable": true,
          "showNavigation": true,
          "groupsWidth": "1px"
        };

        // Instantiate our timeline object.
        timeline = new links.Timeline(document.getElementById('mytimeline'));

        // Draw our timeline with the created data and options
        timeline.draw(data, options);

        $('a[data-toggle="tab"]').on('shown', function (e) {
            if($(e.target).attr('href') == "#timeline") {
                timeline.checkResize();
            }
        })
    });

  }
</r:script>

<div id="mytimeline"></div>