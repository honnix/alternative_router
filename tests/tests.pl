:- begin_tests(arouter).
:- use_module(prolog/arouter).

:- dynamic(visited/1).
:- dynamic(before/1).
:- dynamic(generic/0).

% Root handler.

:- route_get(/, index).

index:-
    assertz(visited(/)).
    
% Handlers for normal paths.

:- route_get(a, get_a).

get_a:-
    assertz(visited(get(a))).

:- route_post(a, post_a).

post_a:-
    assertz(visited(post(a))).

:- route_put(a, put_a).

put_a:-
    assertz(visited(put(a))).

:- route_del(a, del_a).

del_a:-
    assertz(visited(del(a))).

% Handlers with a before action.

:- route_get(b, before(get_b), before_get_b).

before_get_b:-
    assertz(visited(get(b))).

:- route_post(b, before(post_b), before_post_b).

before_post_b:-
    assertz(visited(post(b))).

:- route_put(b, before(put_b), before_put_b).

before_put_b:-
    assertz(visited(put(b))).

:- route_del(b, before(del_b), before_del_b).

before_del_b:-
    assertz(visited(del(b))).

before(Token, Goal):-
    assertz(before(Token)),
    call(Goal).

% Handler for dynamic path.

:- route_get(hello/X, handle_hello(X)).

handle_hello(X):-
    assertz(visited(hello(X))).

% Multiple routes.

:- routes(c, [get, post, put, delete], handle_c).

handle_c:-
    assertz(visited(get(c))),
    assertz(visited(post(c))),
    assertz(visited(put(c))),
    assertz(visited(del(c))).

% Multiple routes. Handlers with a before action.

:- routes(d, [get, post, put, delete], before_list([get_d, post_d, put_d, del_d]), before_handle_d).

before_list(List, Goal) :-
    foreach(member(X, List), assertz(before(X))),
    call(Goal).

before_handle_d:-
    assertz(visited(get(d))),
    assertz(visited(post(d))),
    assertz(visited(put(d))),
    assertz(visited(del(d))).

% Blueprint.

:- blueprint(b1, '/x/y/').
:- b1.route_get(e, get_e).

get_e:-
    assertz(visited(get(e))).

:- blueprint(b2, '/x/z/').
:- route_get_b(b2, f, get_f).

get_f:-
    assertz(visited(get(f))).

% Handlers for specific/general
% routes.

:- route_get(nondet/specific, handle_nondet_specific).

handle_nondet_specific:-
    assertz(visited(specific)).

:- route_get(nondet/Generic, handle_nondet_generic(Generic)).

handle_nondet_generic(Generic):-
    assertz(generic),
    (   Generic = specific
    ->  throw(arouter_next)
    ;   assertz(visited(generic))).

% Custom method.

:- new_route(options, test/custom, test_custom).

test_custom:-
    assertz(visited(custom)).

clean:-
    retractall(visited(_)),
    retractall(before(_)),
    retractall(generic).

test(path1):-
    path_to_route('/', /).
    
test(path2):-
    path_to_route('/a', a).
    
test(path3):-
    path_to_route('/a/b', a/b).
    
test(path4):-
    path_to_route('/a/b/c', a/b/c).
    
test(path5):-
    path_to_route('/a/b/c/', a/b/c/'').

test(route_path_match_1):-
    arouter:route_path_match(A, path),
    nonvar(A), A = path.

test(route_path_match_2):-
    \+ arouter:route_path_match(_, /).

test(route_path_match_3):-
    \+ arouter:route_path_match(abc, /(path, to)).

test(route_path_match_4):-
    arouter:route_path_match(/(path, To), /(path, to)),
    nonvar(To), To = to.

test(route_path_match_5):-
    \+ arouter:route_path_match(_, /(path, to)).

test(route_route_match_1):-
    \+ arouter:route_route_match(_, path).

test(route_route_match_2):-
    arouter:route_route_match(_, _).

test(route_route_match_3):-
    arouter:route_route_match(/, /).

test(route_route_match_4):-
    arouter:route_route_match(path, path).

test(route_route_match_5):-
    \+ arouter:route_route_match(/, path).

test(route_route_match_6):-
    \+ arouter:route_route_match(path, /).

test(route_route_match_7):-
    \+ arouter:route_route_match(_, /).

test(route_route_match_8):-
    \+ arouter:route_route_match(/, _).

test(route_route_match_9):-
    \+ arouter:route_route_match(path, _).

test(route_route_match_10):-
    \+ arouter:route_route_match(path, /(_, _)).

test(route_route_match_11):-
    \+ arouter:route_route_match(_, /(_, _)).

test(route_route_match_12):-
    \+ arouter:route_route_match(/(_, _), _).

test(route_route_match_13):-
    arouter:route_route_match(/(_, _), /(_, _)).
    
test(index, [ setup(clean) ]):-
    route([ path('/'), method(get) ]),
    visited(/).

test(get_a, [ setup(clean) ]):-
    route([ path('/a'), method(get) ]),
    visited(get(a)).

test(post_a, [ setup(clean) ]):-
    route([ path('/a'), method(post) ]),
    visited(post(a)).

test(put_a, [ setup(clean) ]):-
    route([ path('/a'), method(put) ]),
    visited(put(a)).

test(del_a, [ setup(clean) ]):-
    route([ path('/a'), method(delete) ]),
    visited(del(a)).

test(before_get_b, [ setup(clean) ]):-
    route([ path('/b'), method(get) ]),
    visited(get(b)),
    before(get_b).

test(before_post_b, [ setup(clean) ]):-
    route([ path('/b'), method(post) ]),
    visited(post(b)),
    before(post_b).

test(before_put_b, [ setup(clean) ]):-
    route([ path('/b'), method(put) ]),
    visited(put(b)),
    before(put_b).

test(before_del_b, [ setup(clean) ]):-
    route([ path('/b'), method(delete) ]),
    visited(del(b)),
    before(del_b).

test(hello, [ setup(clean) ]):-
    route([ path('/hello/world'), method(get) ]),
    visited(hello(world)).

test(get_c, [ setup(clean) ]):-
    route([ path('/c'), method(get) ]),
    visited(get(c)).

test(post_c, [ setup(clean) ]):-
    route([ path('/c'), method(post) ]),
    visited(post(c)).

test(put_c, [ setup(clean) ]):-
    route([ path('/c'), method(put) ]),
    visited(put(c)).

test(del_c, [ setup(clean) ]):-
    route([ path('/c'), method(delete) ]),
    visited(del(c)).

test(before_get_d, [ setup(clean) ]):-
    route([ path('/d'), method(get) ]),
    visited(get(d)),
    before(get_d).

test(before_post_d, [ setup(clean) ]):-
    route([ path('/d'), method(post) ]),
    visited(post(d)),
    before(post_d).

test(before_put_d, [ setup(clean) ]):-
    route([ path('/d'), method(put) ]),
    visited(put(d)),
    before(put_d).

test(before_del_d, [ setup(clean) ]):-
    route([ path('/d'), method(delete) ]),
    visited(del(d)),
    before(del_d).

test(get_e, [ setup(clean) ]):-
    route([ path('/x/y/e'), method(get) ]),
    visited(get(e)).

test(get_f, [ setup(clean) ]):-
    route([ path('/x/z/f'), method(get) ]),
    visited(get(f)).

test(custom, [ setup(clean) ]):-
    route([ path('/test/custom'), method(options) ]),
    visited(custom).

test(invalid_route):-
    catch((route_get(a(123), _), fail), error(invalid_route(_)), true).

test(remove):-
    route_get(test/remove, true),
    route(get, test/remove, _, _), !,
    route_remove(_, test/remove),
    (   route(get, test/remove, _, _)
    ->  fail
    ;   true).

test(remove_blueprint):-
    route_get_b(b1, test/remove, true),
    route(get, x/y/test/remove, _, _), !,
    route_remove_b(b1, _, test/remove),
    (   route(get, x/y/test/remove, _, _)
    ->  fail
    ;   true).

test(arouter_next, [ setup(clean) ]):-
    \+ generic,
    route([ path('/nondet/specific'), method(get) ]),
    visited(specific),
    generic.

:- end_tests(arouter).
