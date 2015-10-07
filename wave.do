onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -childformat {{/router_tb/INDIN(3) -radix hexadecimal} {/router_tb/INDIN(2) -radix hexadecimal} {/router_tb/INDIN(1) -radix hexadecimal} {/router_tb/INDIN(0) -radix hexadecimal}} -expand -subitemconfig {/router_tb/INDIN(3) {-height 16 -radix hexadecimal} /router_tb/INDIN(2) {-height 16 -radix hexadecimal} /router_tb/INDIN(1) {-height 16 -radix hexadecimal} /router_tb/INDIN(0) {-height 16 -radix hexadecimal}} /router_tb/INDIN
add wave -noupdate -childformat {{/router_tb/OUTDOUT(3) -radix hexadecimal} {/router_tb/OUTDOUT(2) -radix hexadecimal} {/router_tb/OUTDOUT(1) -radix hexadecimal} {/router_tb/OUTDOUT(0) -radix hexadecimal}} -expand -subitemconfig {/router_tb/OUTDOUT(3) {-height 16 -radix hexadecimal} /router_tb/OUTDOUT(2) {-height 16 -radix hexadecimal} /router_tb/OUTDOUT(1) {-height 16 -radix hexadecimal} /router_tb/OUTDOUT(0) {-height 16 -radix hexadecimal}} /router_tb/OUTDOUT
add wave -noupdate -expand /router_tb/uut/OUTBUFF
add wave -noupdate -expand -group INCONTROL /router_tb/INPUSH
add wave -noupdate -expand -group INCONTROL /router_tb/uut/INPOP
add wave -noupdate -expand -group INCONTROL /router_tb/uut/INNOPOP
add wave -noupdate -expand -group OUTCONTROL /router_tb/OUTPOP
add wave -noupdate -expand -group OUTCONTROL /router_tb/uut/OUTPUSH
add wave -noupdate -expand -group OUTCONTROL /router_tb/uut/OUTNOPOP
add wave -noupdate -expand -group OUTCONTROL /router_tb/uut/OUTNOPUSH
add wave -noupdate /router_tb/uut/current_state
add wave -noupdate /router_tb/dataInState
add wave -noupdate /router_tb/RESET
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {98040 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 306
configure wave -valuecolwidth 159
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {78263 ps} {98414 ps}
