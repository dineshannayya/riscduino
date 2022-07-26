########################################
#   Get the Cell wise statistic
#########################################

proc get_statistic {design_name } {

     #puts "Analysising the Statistic ..."
     
     #To get all the lib cells and initialise the counter
     array set libArray {}
     set mylist [get_lib_cells *]
     set lib_cnt 0
     foreach elem $mylist {
         #puts [get_full_name $elem]
         #set libArray($lib_cnt,0) [get_full_name $elem]  
         set libArray($lib_cnt) 0
         #puts "$libArray($lib_cnt)"
         set lib_cnt [expr {$lib_cnt + 1}]
     }
     
    
     #################################################
     # Accumlate the lib count
     ################################################ 
     set mylist1 [get_cells]
     foreach elem1 $mylist1 {
        set Inst [get_full_name $elem1]
        #puts "Searching: ..:: $Inst .." 
        if ([string match "*ANTENNA*" $Inst]) {
          continue
        }
        if ([string match "*FILLER*" $Inst]) {
          continue
        }
        if ([string match "*TAP_*" $Inst]) {
          continue
        }
        set lib  [get_lib_cells -of_objects [get_cells $Inst]]
        set lib_name  [get_full_name $lib]
        #puts "Searching: ..:: $lib_name .." 

        if ([string match "*decap*" $lib_name]) {
          continue
        }
        set lib_cnt 0
        set mylist2 [get_lib_cells *]
        foreach elem2 $mylist2 {
           set ref_lib_name [get_full_name $elem2]
           if { [expr {$ref_lib_name eq $lib_name}] == 1 } {
               set c_lib_cnt $libArray($lib_cnt)
               set libArray($lib_cnt) [expr {$c_lib_cnt + 1}]
               #puts "Lib Matched : $Inst: $lib_name :: $ref_lib_name :: cnt:  $libArray($lib_cnt)"
               break
            }
            set lib_cnt [expr {$lib_cnt + 1}]
        }
     }
     
     
     ##################################################
     ## lib count > 0
     ################################################# 
     set mylist [get_lib_cells *]
     set lib_cnt 0
     set seq_cnt 0
     set comb_cnt 0
     set total_cnt 0
     foreach elem $mylist {
         set ref_lib_name [get_full_name $elem]
         if {$libArray($lib_cnt)  > 0} {
           #puts "Lib Name:  $ref_lib_name :: Count: $libArray($lib_cnt)"
         }
         # Check cell is Sequential OR Combo
         if ([string match "*__df*" $ref_lib_name]) {
           set seq_cnt [expr {$seq_cnt + $libArray($lib_cnt) }]
         } else {
           set comb_cnt [expr {$comb_cnt + $libArray($lib_cnt) }]
         }

         set total_cnt [expr {$total_cnt + $libArray($lib_cnt) }]
         set lib_cnt [expr {$lib_cnt + 1}]
     }
     puts "$design_name :: $total_cnt ::  $comb_cnt ::  $seq_cnt"
     return "$total_cnt $comb_cnt $seq_cnt"
}

