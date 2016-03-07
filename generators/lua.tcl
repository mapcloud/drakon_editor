gen::add_generator Lua gen_lua::generate

namespace eval gen_lua {

variable handlers {}

variable keywords {
and       break     do        else      elseif
    end       false     for       function  if
    in        local     nil       not       or
    repeat    return    then      true      until
    while
}

# Autogenerated with DRAKON Editor 1.27

proc append_sm_names { gdb } {
    #item 1852
    set ids {}
    #item 1825
    $gdb eval {
    	select diagram_id, original, name
    	from diagrams
    	where original is not null
    } {
    	set sm_name $original
    	set new_name "${sm_name}_$name"
    	$gdb eval {
    		update diagrams
    		set name = :new_name
    		where diagram_id = :diagram_id
    	}
    	lappend ids $new_name
    }
    #item 1853
    return $ids
}

proc assign { variable value } {
    #item 1398
    return "$variable = $value"
}

proc bad_case { switch_var select_icon_number } {
    #item 1799
    if {[ string compare -nocase $switch_var "select" ] == 0} {
        #item 1805
        return "error\(\"Condition was not detected.\"\)"
    } else {
        #item 1804
        return "error\($switch_var\)"
    }
}

proc block_close { output depth } {
    #item 1787
    upvar 1 $output result
    set line [ gen::make_indent $depth ]
    append line "end"
    lappend result $line
}

proc change_state { next_state machine_name } {
    #item 1832
    if {$next_state == ""} {
        #item 1836
        return "self.state = nil"
    } else {
        #item 1835
        return "self.state = ${machine_name}_state_${next_state}"
    }
}

proc commentator { text } {
    #item 143
    return "-- $text"
}

proc compare { variable constant } {
    #item 1404
    return "$variable == $constant"
}

proc declare { type name value } {
    #item 1434
    return "local $name = $value"
}

proc else_start { } {
    #item 1530
    return "else"
}

proc elseif_start { } {
    #item 1773
    return "elseif "
}

proc extract_signature { text name } {
    #item 783
    array set props { type function access public }
    set error_message ""
    set parameters {}
    #item 15
    set lines [ gen::separate_from_comments $text ]
    #item 17
    if {[ llength $lines ] == 0} {
        
    } else {
        #item 16
        set first_line [ lindex $lines 0 ]
        set first [ lindex $first_line 0 ]
        #item 589
        if {$first == "#comment"} {
            #item 42
            set props(type) "comment"
        } else {
            #item 1562
            if {$first == "local"} {
                #item 1565
                set props(access) "local"
                #item 1567
                set start_index 1
            } else {
                #item 1566
                set start_index 0
            }
            #item 1854
            variable handlers
            #item 1855
            set is_handler [ contains $handlers $name ]
            #item 1859
            if {$is_handler} {
                #item 1862
                lappend parameters "self"
            } else {
                
            }
            #item 34
            set count [ llength $lines ]
            #item 370001
            set i $start_index
            while { 1 } {
                #item 370002
                if {$i < $count} {
                    
                } else {
                    break
                }
                #item 36
                set current [ lindex $lines $i ]
                #item 1851
                set left [ lindex $current 0 ]
                #item 1856
                if {($is_handler) && (($left == "private") || ($left == "state machine"))} {
                    
                } else {
                    #item 45
                    lappend parameters $current
                }
                #item 370003
                incr i
            }
        }
    }
    #item 793
    set prop_list [ array get props ]
    #item 38
    return [ list $error_message \
    [ gen::create_signature $props(type) $prop_list $parameters "" ] ]
}

proc foreach_check { item_id first second } {
    #item 1676
    set vars [ split_vars $item_id $first ]
    #item 1677
    set var1 [ lindex $vars 0 ]
    #item 1678
    return "$var1 ~= nil"
}

proc foreach_current { item_id first second } {
    #item 1610
    return ""
}

proc foreach_declare { item_id first second } {
    #item 1667
    set iter_var "_iter$item_id"
    set state_var "_state$item_id"
    #item 1618
    return "local $iter_var, $state_var, $first"
}

proc foreach_incr { item_id first second } {
    #item 1673
    set vars [ split_vars $item_id $first ]
    #item 1675
    set iter_var "_iter$item_id"
    set state_var "_state$item_id"
    #item 1674
    set var1 [ lindex $vars 0 ]
    #item 1672
    return "$first = $iter_var\($state_var, $var1\)"
}

proc foreach_init { item_id first second } {
    #item 1668
    set vars [ split_vars $item_id $first ]
    #item 1671
    set iter_var "_iter$item_id"
    set state_var "_state$item_id"
    #item 1669
    set var1 [ lindex $vars 0 ]
    #item 1670
    return "$iter_var, $state_var, $var1 = $second $first = $iter_var\($state_var, $var1\)"
}

proc generate { db gdb filename } {
    #item 1767
    set diagrams [ $gdb eval {
    	select diagram_id
    	from vertices
    	group by diagram_id
    } ]
    #item 17680001
    set _col1768 $diagrams
    set _len1768 [ llength $_col1768 ]
    set _ind1768 0
    while { 1 } {
        #item 17680002
        if {$_ind1768 < $_len1768} {
            
        } else {
            break
        }
        #item 17680004
        set diagram_id [ lindex $_col1768 $_ind1768 ]
        #item 1766
        rewire_lua_for $gdb $diagram_id
        #item 17680003
        incr _ind1768
    }
    #item 1284
    set callbacks [ make_callbacks ]
    #item 1813
    set machines [ sma::extract_many_machines \
     $gdb $callbacks ]
    #item 1814
    variable handlers
    set handlers [ append_sm_names $gdb ]
    #item 1818
    set machine_ctrs [ make_machine_ctrs $machines ]
    #item 1916
    set machine_decl [ make_machine_declares $machines ]
    #item 1812
    set diagrams [ $gdb eval {
    	select diagram_id from diagrams } ]
    #item 18100001
    set _col1810 $diagrams
    set _len1810 [ llength $_col1810 ]
    set _ind1810 0
    while { 1 } {
        #item 18100002
        if {$_ind1810 < $_len1810} {
            
        } else {
            break
        }
        #item 18100004
        set diagram_id [ lindex $_col1810 $_ind1810 ]
        #item 1809
        gen::fix_graph_for_diagram $gdb $callbacks 0 $diagram_id
        #item 18100003
        incr _ind1810
    }
    #item 1279
    set sections { header footer }
    unpack [ gen::scan_file_description $db $sections ] \
    header footer
    #item 1270
    set functions [ gen::generate_functions $db $gdb  \
    	$callbacks 1 ]
    #item 1261
    if {[ graph::errors_occured ]} {
        
    } else {
        #item 1280
        set filename [ replace_extension $filename "lua" ]
        #item 1282
        set fhandle [ open $filename w ]
        
        catch {
        	print_to_file $fhandle $functions \
        		$header $footer $machine_decl $machine_ctrs
        } error_message
        
        catch { close $fhandle }
        #item 1262
        if {$error_message == ""} {
            
        } else {
            #item 1263
            puts $::errorInfo
            error $error_message
        }
    }
}

proc generate_body { gdb diagram_id start_item node_list items incoming } {
    #item 1512
    set callbacks [ make_callbacks ]
    #item 1511
    cbody::generate_body $gdb $diagram_id $start_item $node_list \
        $items $incoming $callbacks
}

proc goto { text } {
    #item 1644
    return "goto $text"
}

proc highlight { tokens } {
    #item 1935
    set result {}
    #item 1936
    set state "idle"
    #item 1976
    variable keywords
    #item 19420001
    set _col1942 $tokens
    set _len1942 [ llength $_col1942 ]
    set _ind1942 0
    while { 1 } {
        #item 19420002
        if {$_ind1942 < $_len1942} {
            
        } else {
            break
        }
        #item 19420004
        set token [ lindex $_col1942 $_ind1942 ]
        #item 2024
        lassign $token type text
        #item 19370001
        if {$state == "idle"} {
            #item 2079
            set state [ idle_default \
              $keywords result $type $text ]
        } else {
            #item 19370002
            if {$state == "string"} {
                #item 19790001
                if {$text == "\""} {
                    #item 1986
                    lappend result \
                      $colors::syntax_string
                    #item 1987
                    set state "idle"
                } else {
                    #item 19790002
                    if {$text == "\\"} {
                        #item 2025
                        lappend result \
                          $colors::syntax_string
                        #item 1988
                        set state "escaping"
                    } else {
                        #item 19790003
                        if {$text == "\n"} {
                            #item 2026
                            lappend result \
                              $colors::syntax_string
                            #item 1991
                            set state "idle"
                        } else {
                            #item 2027
                            lappend result \
                              $colors::syntax_string
                        }
                    }
                }
            } else {
                #item 19370003
                if {$state == "escaping"} {
                    #item 1993
                    lappend result $colors::syntax_string
                    #item 2009
                    if {$text == "\n"} {
                        #item 2011
                        set state "idle"
                    } else {
                        #item 1992
                        set state "string"
                    }
                } else {
                    #item 19370004
                    if {$state == "atom"} {
                        #item 2001
                        lappend result $colors::syntax_string
                        #item 19940001
                        if {$text == "'"} {
                            #item 2002
                            set state "idle"
                        } else {
                            #item 19940002
                            if {$text == "\\"} {
                                #item 2003
                                set state "atom escaping"
                            } else {
                                #item 19940003
                                if {$text == "\n"} {
                                    #item 2006
                                    set state "idle"
                                } else {
                                    
                                }
                            }
                        }
                    } else {
                        #item 19370005
                        if {$state == "atom escaping"} {
                            #item 2008
                            lappend result \
                             $colors::syntax_string
                            #item 2012
                            if {$text == "\n"} {
                                #item 2014
                                set state "idle"
                            } else {
                                #item 2007
                                set state "atom"
                            }
                        } else {
                            #item 19370006
                            if {$state == "comment start"} {
                                #item 2037
                                if {$text == "-"} {
                                    #item 2036
                                    lappend result \
                                      $colors::syntax_comment \
                                      $colors::syntax_comment
                                    #item 2046
                                    set state "comment"
                                } else {
                                    #item 2081
                                    lappend result \
                                     $colors::syntax_operator
                                    #item 2080
                                    set state [ idle_default \
                                      $keywords result $type $text ]
                                }
                            } else {
                                #item 19370007
                                if {$state == "comment"} {
                                    
                                } else {
                                    #item 19370008
                                    error "Unexpected switch value: $state"
                                }
                                #item 2019
                                lappend result \
                                  $colors::syntax_comment
                                #item 2020
                                if {$text == "\n"} {
                                    #item 2022
                                    set state "idle"
                                } else {
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
        #item 19420003
        incr _ind1942
    }
    #item 2082
    if {$state == "comment start"} {
        #item 2085
        lappend result \
         $colors::syntax_operator
    } else {
        
    }
    #item 1934
    return $result
}

proc idle_default { keywords result_name type text } {
    #item 2045
    upvar 1 $result_name result
    #item 20470001
    if {$text == "\""} {
        #item 2070
        lappend result \
          $colors::syntax_string
        #item 2054
        set state "string"
    } else {
        #item 20470002
        if {$text == "'"} {
            #item 2071
            lappend result \
              $colors::syntax_string
            #item 2055
            set state "atom"
        } else {
            #item 20470003
            if {$text == "-"} {
                #item 2074
                set state "comment start"
            } else {
                #item 20560001
                if {$type == "op"} {
                    #item 2064
                    lappend result \
                      $colors::syntax_operator
                    #item 2075
                    set state "idle"
                } else {
                    #item 20560002
                    if {$type == "number"} {
                        #item 2063
                        lappend result \
                          $colors::syntax_number
                        #item 2076
                        set state "idle"
                    } else {
                        #item 20560003
                        if {($type == "token") && ([contains $keywords $text])} {
                            #item 2068
                            lappend result \
                              $colors::syntax_keyword
                            #item 2086
                            set state "idle"
                        } else {
                            #item 2065
                            lappend result \
                              $colors::syntax_identifier
                            #item 2087
                            set state "idle"
                        }
                    }
                }
            }
        }
    }
    #item 2078
    return $state
}

proc if_end { } {
    #item 1526
    return " then"
}

proc if_start { } {
    #item 1522
    return "if "
}

proc is_for { text } {
    #item 1684
    set trimmed [ string trim $text]
    #item 1685
    set result [ string match "for *" $trimmed ]
    #item 1686
    return $result
}

proc make_callbacks { } {
    #item 1192
    set callbacks {}
    #item 1194
    gen::put_callback callbacks assign    gen_lua::assign
    gen::put_callback callbacks compare   gen_lua::compare
    gen::put_callback callbacks compare2  gen_lua::compare
    gen::put_callback callbacks bad_case  gen_lua::bad_case
    
    gen::put_callback callbacks body      gen_lua::generate_body
    gen::put_callback callbacks signature gen_lua::extract_signature
    gen::put_callback callbacks and       gen_lua::p.and
    gen::put_callback callbacks or        gen_lua::p.or
    gen::put_callback callbacks not       gen_lua::p.not
    gen::put_callback callbacks declare   gen_lua::declare
    
    gen::put_callback callbacks comment   gen_lua::commentator
    #item 1505
    gen::put_callback callbacks if_start     gen_lua::if_start
    gen::put_callback callbacks while_start     gen_lua::while_start
    gen::put_callback callbacks elseif_start     gen_lua::elseif_start
    gen::put_callback callbacks if_end       gen_lua::if_end
    gen::put_callback callbacks pass       gen_lua::pass
    gen::put_callback callbacks else_start   gen_lua::else_start
    gen::put_callback callbacks block_close  gen_lua::block_close
    gen::put_callback callbacks return_none  gen_lua::return_none
    gen::put_callback callbacks goto         gen_lua::goto
    gen::put_callback callbacks tag          gen_lua::tag
    gen::put_callback callbacks break        "break"
    #item 1619
    gen::put_callback callbacks for_check		gen_lua::foreach_check
    gen::put_callback callbacks for_current		gen_lua::foreach_current
    gen::put_callback callbacks for_init		gen_lua::foreach_init
    gen::put_callback callbacks for_incr		gen_lua::foreach_incr
    gen::put_callback callbacks for_declare		gen_lua::foreach_declare
    gen::put_callback callbacks shelf gen_lua::shelf
    #item 1826
    gen::put_callback callbacks change_state 	gen_lua::change_state
    gen::put_callback callbacks fsm_merge   0
    gen::put_callback callbacks native_foreach gen_lua::native_foreach
    #item 1193
    return $callbacks
}

proc make_machine_ctr { name states param_names messages } {
    #item 1890
    set lines {}
    #item 18880001
    set _col1888 $states
    set _len1888 [ llength $_col1888 ]
    set _ind1888 0
    while { 1 } {
        #item 18880002
        if {$_ind1888 < $_len1888} {
            
        } else {
            break
        }
        #item 18880004
        set state [ lindex $_col1888 $_ind1888 ]
        #item 18930001
        set _col1893 $messages
        set _len1893 [ llength $_col1893 ]
        set _ind1893 0
        while { 1 } {
            #item 18930002
            if {$_ind1893 < $_len1893} {
                
            } else {
                break
            }
            #item 18930004
            set message [ lindex $_col1893 $_ind1893 ]
            #item 1895
            lappend lines \
             "${name}_state_${state}.$message = ${name}_${state}_${message}"
            #item 18930003
            incr _ind1893
        }
        #item 1896
        lappend lines "${name}_state_${state}.state_name = \"$state\""
        #item 18880003
        incr _ind1888
    }
    #item 1899
    set params [ lrange $param_names 1 end ]
    set params [ linsert $params 0 "self" ]
    set params_str [ join $params ", " ]
    #item 1897
    lappend lines "function make_${name}\(\)"
    #item 1902
    lappend lines \
     "  local obj = {}"
    lappend lines \
     "  obj.type_name = \"$name\""
    #item 1903
    set first [ lindex $states 0 ]
    lappend lines "  obj.state = ${name}_state_${first}"
    #item 19000001
    set _col1900 $messages
    set _len1900 [ llength $_col1900 ]
    set _ind1900 0
    while { 1 } {
        #item 19000002
        if {$_ind1900 < $_len1900} {
            
        } else {
            break
        }
        #item 19000004
        set message [ lindex $_col1900 $_ind1900 ]
        #item 1904
        lappend lines \
         "  obj.$message = function\($params_str\)"
        lappend lines \
         "    self.state.$message\($params_str\)"
        lappend lines \
         "  end"
        #item 19000003
        incr _ind1900
    }
    #item 1898
    lappend lines "  return obj"
    lappend lines "end"
    #item 1886
    return [ join $lines "\n" ]
}

proc make_machine_ctrs { machines } {
    #item 1869
    set result ""
    #item 18670001
    set _col1867 $machines
    set _len1867 [ llength $_col1867 ]
    set _ind1867 0
    while { 1 } {
        #item 18670002
        if {$_ind1867 < $_len1867} {
            
        } else {
            break
        }
        #item 18670004
        set machine [ lindex $_col1867 $_ind1867 ]
        #item 1864
        set states [ dict get $machine "states"]
        set param_names [ dict get $machine "param_names" ]
        set messages [ dict get $machine "messages" ]
        set name [ dict get $machine "name" ]
        #item 1887
        set ctr \
        [make_machine_ctr $name $states $param_names $messages]
        #item 1863
        append result $ctr
        #item 18670003
        incr _ind1867
    }
    #item 1843
    return $result
}

proc make_machine_declares { machines } {
    #item 1913
    set lines {}
    #item 19110001
    set _col1911 $machines
    set _len1911 [ llength $_col1911 ]
    set _ind1911 0
    while { 1 } {
        #item 19110002
        if {$_ind1911 < $_len1911} {
            
        } else {
            break
        }
        #item 19110004
        set machine [ lindex $_col1911 $_ind1911 ]
        #item 1910
        set states [ dict get $machine "states"]
        set name [ dict get $machine "name" ]
        #item 19180001
        set _col1918 $states
        set _len1918 [ llength $_col1918 ]
        set _ind1918 0
        while { 1 } {
            #item 19180002
            if {$_ind1918 < $_len1918} {
                
            } else {
                break
            }
            #item 19180004
            set state [ lindex $_col1918 $_ind1918 ]
            #item 1914
            lappend lines "${name}_state_${state} = \{\}"
            #item 19180003
            incr _ind1918
        }
        #item 19110003
        incr _ind1911
    }
    #item 1915
    return [ join $lines "\n" ]
}

proc native_foreach { for_it for_var } {
    #item 2093
    return "for $for_it in $for_var do"
}

proc normalize_for { var start end } {
    #item 1726
    return "$var = $start; $var <= $end; $var = $var + 1"
}

proc p.and { left right } {
    #item 1414
    return "($left) and ($right)"
}

proc p.not { operand } {
    #item 1426
    return "not ($operand)"
}

proc p.or { left right } {
    #item 1422
    return "($left) or ($right)"
}

proc parse_for { item_id text } {
    #item 1692
    set tokens [ to_tokens $text ]
    #item 1711
    if {[ llength $tokens ] < 6} {
        #item 1714
        error "Wrong 'for' syntax in item $item_id"
    } else {
        #item 1694
        unpack $tokens for var eq start comma
        #item 1715
        if {(($for == "for") && ($eq == "=")) && ($comma == ",")} {
            #item 1718
            set comma_index [ string first "," $text ]
            #item 1719
            set target_index [ expr { $comma_index + 1 } ]
            set target [ string range $text $target_index end ]
            set end [ string trim $target ]
            #item 1720
            return [ list $var $start $end ]
        } else {
            #item 1714
            error "Wrong 'for' syntax in item $item_id"
        }
    }
}

proc parse_foreach { item_id init } {
    #item 1625
    set length [ llength $init ]
    #item 1627
    if {$length == 2} {
        
    } else {
        #item 1626
        set message "item id: $item_id, wrong syntax in foreach. Should be: Type variable; collection"
    }
    #item 1630
    return $init
}

proc pass { } {
    #item 1781
    return ""
}

proc print_function { fhandle function } {
    #item 1571
    unpack $function diagram_id name signature body
    unpack $signature type prop_list parameters returns
    array set props $prop_list
    #item 1572
    set type   $props(type)
    set access $props(access)
    #item 1576
    set line ""
    set result {}
    #item 1575
    if {$type == "comment"} {
        
    } else {
        #item 1577
        if {$access == "local"} {
            #item 1580
            append line "local "
        } else {
            
        }
        #item 1581
        append line "function "
        #item 536
        append line "$name\("
        #item 588
        set param_count [ llength $parameters ]
        #item 5400001
        set i 0
        while { 1 } {
            #item 5400002
            if {$i < $param_count} {
                
            } else {
                break
            }
            #item 543
            set parameter_info [ lindex $parameters $i ]
            set parameter [ lindex $parameter_info 0 ]
            #item 541
            append line $parameter
            #item 544
            if {$i == $param_count - 1} {
                
            } else {
                #item 545
                append line ", "
            }
            #item 5400003
            incr i
        }
        #item 542
        append line "\)"
        #item 552
        lappend result $line
        #item 5830001
        set _col583 $body
        set _len583 [ llength $_col583 ]
        set _ind583 0
        while { 1 } {
            #item 5830002
            if {$_ind583 < $_len583} {
                
            } else {
                break
            }
            #item 5830004
            set line [ lindex $_col583 $_ind583 ]
            #item 582
            lappend result "    $line"
            #item 5830003
            incr _ind583
        }
        #item 585
        lappend result "end"
        #item 10200001
        set _col1020 $result
        set _len1020 [ llength $_col1020 ]
        set _ind1020 0
        while { 1 } {
            #item 10200002
            if {$_ind1020 < $_len1020} {
                
            } else {
                break
            }
            #item 10200004
            set line [ lindex $_col1020 $_ind1020 ]
            #item 1022
            puts $fhandle $line
            #item 10200003
            incr _ind1020
        }
        #item 1023
        puts $fhandle ""
    }
}

proc print_to_file { fhandle functions header footer machine_decl machine_ctrs } {
    #item 1561
    put_credits $fhandle
    #item 1559
    puts $fhandle $header
    #item 1917
    puts $fhandle $machine_decl
    #item 15680001
    set _col1568 $functions
    set _len1568 [ llength $_col1568 ]
    set _ind1568 0
    while { 1 } {
        #item 15680002
        if {$_ind1568 < $_len1568} {
            
        } else {
            break
        }
        #item 15680004
        set function [ lindex $_col1568 $_ind1568 ]
        #item 1570
        print_function $fhandle $function
        #item 15680003
        incr _ind1568
    }
    #item 1819
    puts $fhandle $machine_ctrs
    #item 1560
    puts $fhandle $footer
}

proc put_credits { fhandle } {
    #item 180
    set version [ version_string ]
    puts $fhandle \
        "-- Autogenerated with DRAKON Editor $version"
}

proc return_none { } {
    #item 1640
    return "return"
}

proc rewire_lua_for { gdb diagram_id } {
    #item 1732
    set starts [ $gdb eval {
    	select vertex_id
    	from vertices
    	where type = 'loopstart'
    		and text like 'for %'
    		and diagram_id = :diagram_id
    } ]
    #item 1733
    set loop_vars {}
    #item 17340001
    set _col1734 $starts
    set _len1734 [ llength $_col1734 ]
    set _ind1734 0
    while { 1 } {
        #item 17340002
        if {$_ind1734 < $_len1734} {
            
        } else {
            break
        }
        #item 17340004
        set vertex_id [ lindex $_col1734 $_ind1734 ]
        #item 1736
        unpack [ $gdb eval { 
        	select text, item_id
        	from vertices
        	where vertex_id = :vertex_id
        } ] text item_id
        #item 1737
        unpack [ parse_for $item_id $text ] var start end
        #item 1738
        set new_text [ normalize_for $var $start $end ]
        #item 1739
        $gdb eval {
        	update vertices
        	set text = :new_text
        	where vertex_id = :vertex_id
        }
        #item 1740
        lappend loop_vars $var
        #item 17340003
        incr _ind1734
    }
    #item 1753
    set var_list [ lsort -unique $loop_vars ]
    #item 1759
    if {$var_list == {}} {
        
    } else {
        #item 1755
        set vars_comma [ join $var_list ", " ]
        #item 1756
        set declaration "local $vars_comma"
        #item 1757
        gen::p.save_declare_kernel $gdb $diagram_id $declaration 1
    }
}

proc shelf { primary secondary } {
    #item 1793
    return "$secondary = $primary"
}

proc split_vars { $item_id var_list } {
    #item 1652
    set raw [ split $var_list "," ]
    #item 1653
    set result {}
    #item 16550001
    set _col1655 $raw
    set _len1655 [ llength $_col1655 ]
    set _ind1655 0
    while { 1 } {
        #item 16550002
        if {$_ind1655 < $_len1655} {
            
        } else {
            break
        }
        #item 16550004
        set part [ lindex $_col1655 $_ind1655 ]
        #item 1657
        set stripped [ string trim $part ]
        #item 1658
        if {$stripped == ""} {
            
        } else {
            #item 1661
            lappend result $stripped
        }
        #item 16550003
        incr _ind1655
    }
    #item 1663
    if {$result == {}} {
        #item 1662
        error "Bad variable list in $item_id"
    } else {
        
    }
    #item 1654
    return $result
}

proc tag { text } {
    #item 1634
    return "\:\:$text\:\:"
}

proc to_tokens { text } {
    #item 1700
    set tokens [ search::to_tokens $text ]
    #item 1701
    set result {}
    #item 17030001
    set _col1703 $tokens
    set _len1703 [ llength $_col1703 ]
    set _ind1703 0
    while { 1 } {
        #item 17030002
        if {$_ind1703 < $_len1703} {
            
        } else {
            break
        }
        #item 17030004
        set token [ lindex $_col1703 $_ind1703 ]
        #item 1705
        set text [ lindex $token 0 ]
        #item 1706
        set trimmed [ string trim $text ]
        #item 1708
        if {$trimmed == ""} {
            
        } else {
            #item 1707
            lappend result $text
        }
        #item 17030003
        incr _ind1703
    }
    #item 1702
    return $result
}

proc while_start { } {
    #item 1777
    return "while true do"
}

}
