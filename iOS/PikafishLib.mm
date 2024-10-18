//
//  PikafishLib.m
//  ChessHeaven
//
//  Created by Vickson on 10/09/2020.
//  Copyright © 2020 Madness. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iostream>
#include "Bitboard.h"
#include "Position.h"
#include "search.h"
#include "uci.h"
#include "thread.h"
#include "pawn.h"
#include "psqt.h"

@interface PikafishLib : NSObject
-(void) init: (double) skill : (double) time;
-(void) init: (double) skill : (double) time : (const char*) customFEN;
-(void) setPosition : (const char*) fen;
-(void) callMove: (int) from : (int) to;
-(int) searchMove;
-(void) undoMove;
-(void) newGame;
-(bool) drawCheck;
-(void) releaseResource;
@end

@implementation PikafishLib {
    Position _pos;
    StateListPtr _states;
    std::deque<Move> _moveHistory;
}
-(void) init: (double) skill : (double) time;
{
    UCI::init(Options, skill, time);
    PSQT::init();
    Bitboards::init();
    Position::init();
    Bitbases::init(); //unable to figure out
    Search::init(); //unable to figure out
    Pawns::init(); //unable to figure out
    Threads.set(Options["Threads"]);
    Search::clear(); // After threads are up

    UCI::init(_pos, _states);
    std::cout << "created stockfish instance skill : " << skill << " time : " << time << "\n";
}

-(void) init: (double) skill : (double) time : (const char*) customFEN;
{
    UCI::init(Options, skill, time);
    PSQT::init();
    Bitboards::init();
    Position::init();
    Bitbases::init(); //unable to figure out
    Search::init(); //unable to figure out
    Pawns::init(); //unable to figure out
    Threads.set(Options["Threads"]);
    Search::clear(); // After threads are up

    UCI::init(_pos, _states, customFEN);
    std::cout << "created stockfish instance skill : " << skill << " time : " << time << "\n";
}

//didn't use, might not be able to use this raw
-(void) setPosition : (const char*) fen
{
    UCI::set_position(_pos, _states, fen);
}

-(void) callMove: (int) from : (int) to
{
    UCI::init_move(from, to, _pos, _moveHistory);
}

-(int) searchMove
{
    Move m = UCI::think(_pos, _moveHistory);

    return (m);
}

-(void) undoMove
{
    UCI::undo_move(_pos, _moveHistory);
}

-(void) newGame
{
    UCI::new_game(_pos, _states, _moveHistory);
}

-(bool) drawCheck
{
    bool draw = UCI::is_game_draw(_pos);
    return draw;
}

-(void) releaseResource
{
    UCI::release_resources(_pos);
}
@end

extern "C"
{
    PikafishLib *ai = [[PikafishLib alloc] init];

    void cpp_init_pikafish(double skill, double time)
    {
        [ai init:skill :time];
    }

    void cpp_init_custom_pikafish(double skill, double time, const char* customFEN)
    {
        [ai init:skill :time :customFEN];
    }

    void cpp_set_position(std::string fen)
    {
        [ai setPosition:fen.c_str()];
    }

    void cpp_call_move(int from, int to)
    {
        [ai callMove:from :to];
    }

    int cpp_search_move()
    {
        int m = [ai searchMove];
        return m;
    }

    void cpp_undo_move()
    {
        [ai undoMove];
    }

    void cpp_new_game()
    {
        [ai newGame];
    }

    bool cpp_draw_check()
    {
        bool draw = [ai drawCheck];
        return draw;
    }

    void cpp_release_resource()
    {
        [ai releaseResource];
    }
}
