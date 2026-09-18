#!/bin/bash
sleep 5

$HOME/Conky/conky.AppImage -c $HOME/Conky/conky_text.conf &
$HOME/Conky/conky.AppImage -c $HOME/Conky/conky_cpu_graph.conf &
$HOME/Conky/conky.AppImage -c $HOME/Conky/conky_uptodate.conf &
