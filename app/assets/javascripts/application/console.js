var mumuki = mumuki || {};
(function (mumuki) {
  function historicalQueries() {
    var queries = $('#historical_queries').val();
    if (queries) {
      return JSON.parse(queries);
    } else {
      return [];
    }
  }
  function renderPrompt() {
    var prompt = $('#prompt').attr('value');
    if (prompt && prompt.indexOf('ム') >= 0) {
      $('.jquery-console-prompt-label')
        .html('')
        .append('<i class="text-primary da da-mumuki"></i>')
        .append('<span>&nbsp;&nbsp;</span>');
    }
  }

  function classForStatus(status) {
    return 'jquery-console-message-' + (status === 'passed' ? 'value' : 'error');
  }

  function reportStatus(message, status, report) {
    report([{
      msg: message,
      className: classForStatus(status)
    }]);
    renderPrompt();
  }

  function clearConsole() {
    $('.jquery-console-message-error').remove();
    $('.jquery-console-message-value').remove();
    $('.jquery-console-prompt-box:not(:last)').remove()
  }

  function QueryConsole() {
    this.endpoint = $('#console_endpoint').val();
    this.token = new mumuki.CsrfToken();
    this.statefulConsole = $('#stateful_console').val() === "true";
    this.lines = [];
  }

  QueryConsole.prototype = {
    newQuery: function (line) {
      var cookies = this.statefulConsole ? this.lines : [];
      return new Query(line, cookies, this);
    },
    clearState: function () {
      this.lines = [];
      clearConsole();
    },
    sendQuery: function (queryContent) {
      this.controller.promptText(queryContent);
      this.controller.typer.commandTrigger();
    },
    preloadQuery: function (queryWithResults) {
      this.lines.push(queryWithResults.query);
      this.enqueuePreloadedQuery(queryWithResults);
      this.sendQuery(queryWithResults.query);
    },
    enqueuePreloadedQuery: function (queryWithResults) {
      this.preloadedQuery = queryWithResults;
    },
    dequeuePreloadedQuery: function () {
      var result = this.preloadedQuery;
      this.preloadedQuery = undefined;
      return result;
    },
    preloadHistoricalQueries: function () {
      var self = this;
      historicalQueries().forEach(function (queryWithResults) {
        self.preloadQuery(queryWithResults);
      });
    }
  };

  function Query(line, cookie, console) {
    this.console = console;
    this.line = line;
    this.cookie = cookie;
  }

  Query.prototype = {
    get token() {
      return this.console.token;
    },
    get content() {
      var firstEditor = mumuki.page.editors[0];
      if (firstEditor && $("#include_solution").prop("checked"))
        return firstEditor.getValue();
      else
        return '';
    },
    submit: function (report, queryConsole, line) {
      var self = this;
      var preloadedQuery = queryConsole.dequeuePreloadedQuery();
      if (preloadedQuery) {
        return reportStatus(preloadedQuery.result, preloadedQuery.status, report);
      }

      $.ajax(self._request).done(function (response) {
        if (response.query_result) {
          self.displayGoalResult(response);
          response = response.query_result;
        }
        self.displayQueryResult(report, queryConsole, line, response);
      }).fail(function (response) {
        reportStatus(response.responseText, 'failed', report);
      });
    },
    displayGoalResult: function (response) {
      if (response.status == 'passed') {
        $('.submission-results').show();
        $('.submission-results').html(response.corollary);
        mumuki.pin.scroll();
      } else {
        $('.submission-results').hide();
        $('.progress-list-item.active').attr('class', "progress-list-item text-center danger active");
      }
    },
    displayQueryResult: function (report, queryConsole, line, response) {
      var status = response.status === 'errored' ? 'failed' : response.status;

      if (status === 'passed') queryConsole.lines.push(line);
      reportStatus(response.result, status, report);
    },
    get _request() {
      var self = this;
      return self.token.newRequest({
        url: self._requestUrl,
        type: 'POST',
        data: self._requestData
      })
    },
    get _requestUrl() {
      return this.console.endpoint;
    },
    get _requestData() {
      return {content: this.content, query: this.line, cookie: this.cookie};
    }
  };


  mumuki.load(function () {
    var prompt = $('#prompt').attr('value');
    var queryConsole = new QueryConsole();

    $('.console-reset').click(function () {
      queryConsole.clearState();
    });

    queryConsole.controller = $('.console').console({
      promptLabel: prompt + ' ',
      commandValidate: function (line) {
        return line !== "";
      },
      commandHandle: function (line, report) {
        queryConsole.newQuery(line).submit(report, queryConsole, line);
      },
      autofocus: !!$('#solution_editor_bottom').val(),
      animateScroll: true,
      promptHistory: true
    });

    renderPrompt();
    queryConsole.preloadHistoricalQueries();
  });

}(mumuki));
