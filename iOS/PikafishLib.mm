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

using namespace Stockfish;

@interface PikafishLib : NSObject
-(void) init: (double) skill : (double) time : (const char*) path;
-(void) init: (double) skill : (double) time : (const char*) customFEN : (const char*) path;
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
    std::unique_ptr<UCIEngine> uci;  // Smart pointer to UCIEngine
}
-(void) init: (double) skill : (double) time : (const char*) path;
{
    Bitboards::init();
    Position::init();

    uci = std::make_unique<UCIEngine>(skill, time, path);
    
    Tune::init(uci->engine_options());
    
    uci->new_game(_pos, _states, _moveHistory);
    uci->init(_pos, _states);
    std::cout << "created stockfish instance skill : " << skill << " time : " << time << "\n";
}

-(void) init: (double) skill : (double) time : (const char*) customFEN  : (const char*) path;
{
    Bitboards::init();
    Position::init();

    uci = std::make_unique<UCIEngine>(skill, time, path);
    
    Tune::init(uci->engine_options());
    
    uci->new_game(_pos, _states, _moveHistory);
    uci->init(_pos, _states, customFEN);
    std::cout << "created stockfish instance skill : " << skill << " time : " << time << "\n";
}

//didn't use, might not be able to use this raw
-(void) setPosition : (const char*) fen
{
    uci->set_position(_pos, _states, fen);
}

-(void) callMove: (int) from : (int) to
{
    uci->init_move(from, to, _pos, _moveHistory);
}

-(int) searchMove
{
    Move m = uci->think(_pos, _moveHistory);

    return m.raw();
}

-(void) undoMove
{
    uci->undo_move(_pos, _moveHistory);
}

-(void) newGame
{
    uci->new_game(_pos, _states, _moveHistory);
}

-(bool) drawCheck
{
    bool draw = uci->is_game_draw(_pos);
    return draw;
}

-(void) releaseResource
{
    uci->release_resources(_pos);
}
@end

extern "C"
{
    PikafishLib *ai = [[PikafishLib alloc] init];

    void cpp_init_pikafish(double skill, double time, const char* path)
    {
        [ai init:skill :time :path];
    }

    void cpp_init_custom_pikafish(double skill, double time, const char* customFEN, const char* path)
    {
        [ai init:skill :time :customFEN :path];
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
