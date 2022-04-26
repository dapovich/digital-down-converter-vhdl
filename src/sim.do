onbreak resume
onerror resume
vsim -voptargs=+acc work.testbench
add wave sim:/testbench/tbClk
add wave sim:/testbench/tbRst
add wave sim:/testbench/tbOutHfSignal
add wave sim:/testbench/tbSin
add wave sim:/testbench/tbCos
add wave sim:/testbench/tbInFilterQ
add wave sim:/testbench/tbInFilterI
add wave sim:/testbench/tbOutFilterQ
add wave sim:/testbench/tbOutFilterI
set NumericStdNoWarnings 1
run -all
