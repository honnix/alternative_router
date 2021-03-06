:- module(example_cliopatria, []).

:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_files)).
:- use_module(library(http/http_wrapper)).
:- use_module(library(arouter)).

:- http_handler('/example_cliopatria/', route_with_fallbacks([example_cliopatria:handle_static, example_cliopatria:handle_404]), [prefix]).

:- blueprint(ex, '/example_cliopatria/').
:- routes_b(ex, hello/Name, [get, post], handle_hello(Name)).
:- ex.routes(hello1/Name, [get, post], handle_hello(Name)).

:- routes(example_cliopatria/goodbye/Name, [get, post], handle_goodbye(Name)).

handle_hello(Name) :-
    http_current_request(Request),
    debug(example_cliopatria, 'Request ~w', [Request]),
    (   memberchk(method(post), Request)
    ->  http_read_json(Request, JSON),
        debug(example_cliopatria, 'JSON ~w', [JSON])
    ;   true
    ),
    format('Content-Type: text/plain; charset=UTF-8~n~n'),
    format('Hello ~w', [Name]).

handle_goodbye(Name) :-
    http_current_request(Request),
    debug(example_cliopatria, 'Request ~w', [Request]),
    (   memberchk(method(post), Request)
    ->  http_read_json(Request, JSON),
        debug(example_cliopatria, 'JSON ~w', [JSON])
    ;   true
    ),
    format('Content-Type: text/plain; charset=UTF-8~n~n'),
    format('Goodbye ~w', [Name]).

handle_static :-
    setting(cpack:package_directory, PackageDir),
    format(atom(Path), '~w/example_cliopatria/web/app', [PackageDir]),
    http_current_request(Request),
    http_reply_from_files(Path, [], Request).

handle_404 :-
    http_current_request(Request),
    http_404([], Request).
