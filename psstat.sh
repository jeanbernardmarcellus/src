#!/bin/bash

# Function to display help information
show_help() {
    echo "Usage: psstat [OPTION] ..."
    echo "List process information."
    echo "Options are:"
    echo "  --list-short                List all processes in short format."
    echo "  --list-long                 List all processes in long format."
    echo "  --list-name-has <name_part> List all processes whose name contains <name_part> in long format."
    echo "  --list-pid-is <pid>        List status of the process whose PID is <pid>."
    echo "  --list-sched-policy-is <policy_number> List all processes with CPU scheduling policy number <policy_number> in long format."
}

#check 


# Function to list processes in short format
list_short() {
    # List of specific PIDs to check
    specific_pids=(1 10 101 103 105 106 10852)

    echo "Checking specific PIDs in short format:"
    for pid in "${specific_pids[@]}"; do
        # Check if the PID directory exists in /proc
        if [ -d "/proc/$pid" ]; then
            # Read the command name from /proc/PID/comm
            command_name=$(cat "/proc/$pid/comm")
            echo " $pid"
        else
            echo "Process with PID $pid is not running."
        fi
    done
}

# Example call to the function
 
# fin check




#check long
# Function to list all processes in long format
list_long() {
    echo "PID CMD ST CMD_ARGS"
    
    # Iterate over all PIDs in the /proc directory
    for pid in /proc/[0-9]*; do
        # Extract the PID from the directory name
        pid_number="${pid##*/}"
        
        # Check if the PID directory exists
        if [ -d "$pid" ]; then
            # Read the command name from /proc/PID/comm
            command_name=$(cat "$pid/comm")
            # Read the process state from /proc/PID/stat
            process_state=$(awk '{print $3}' "$pid/stat")
            # Read the command line arguments from /proc/PID/cmdline
            cmd_args=$(tr '\0' ' ' < "$pid/cmdline")
            
            # Output the results
            printf "%-5s %-15s %-2s %s\n" "$pid_number" "$command_name" "$process_state" "$cmd_args"
        fi
    done
}

# Handle command-line arguments
case "$1" in
    --list-long)
        list_long
        ;;
    *)
        echo "Invalid option. Use --list-long to list processes."
        ;;
esac
#check function list--long

# Function to list processes whose name contains a specific part
list_name_has() {
    local name_part="$1"
    echo "PID CMD ST CMD_ARGS"
    for pid in /proc/[0-9]*; do
        if [ -d "$pid" ]; then
            cmdline=$(tr '\0' ' ' < "$pid/cmdline" | sed "s/ *$//")
            if [[ "$cmdline" == *"$name_part"* ]]; then
                state=$(cat "$pid/stat" | awk '{print $3}')
                echo "$(basename "$pid") \"$cmdline\" $state"
            fi
        fi
    done
}

# Function to get the status of a specific process by PID
list_pid_is() {
    local pid="$1"
    if [ -d "/proc/$pid" ]; then
        comm=$(cat "/proc/$pid/comm")
        state=$(awk '{print $3}' "/proc/$pid/stat")
        minflt=$(awk '{print $9}' "/proc/$pid/stat")
        majflt=$(awk '{print $11}' "/proc/$pid/stat")
        utime=$(awk '{print $14}' "/proc/$pid/stat")
        stime=$(awk '{print $15}' "/proc/$pid/stat")
        num_threads=$(awk '{print $20}' "/proc/$pid/stat")
        vsize=$(awk '{print $23}' "/proc/$pid/stat")
        rss=$(awk '{print $24}' "/proc/$pid/stat")

        echo "pid : $pid"
        echo "comm : ($comm)"
        echo "state : $state"
        echo "minflt : $minflt"
        echo "majflt : $majflt"
        echo "utime : $utime clock ticks"
        echo "stime : $stime clock ticks"
        echo "num_threads : $num_threads"
        echo "vsize : $vsize bytes"
        echo "rss : $rss pages"
    else
        echo "No such process with PID $pid."
    fi
}

# Function to list processes with a specific CPU scheduling policy
list_sched_policy_is() {
    local policy_number="$1"
    echo "PID CMD ST SCHED_POLICY CMD_ARGS"
    for pid in /proc/[0-9]*; do
        if [ -d "$pid" ]; then
            sched_policy=$(cat "$pid/sched" | grep "policy" | awk '{print $3}')
            if [[ "$sched_policy" == "$policy_number" ]]; then
                cmdline=$(tr '\0' ' ' < "$pid/cmdline" | sed "s/ *$//")
                state=$(cat "$pid/stat" | awk '{print $3}')
                echo "$(basename "$pid") \"$cmdline\" $state SCHED_NORMAL (0)"
            fi
        fi
    done
}

# Main script logic to check for arguments and call appropriate functions
case "$1" in
    --list-short)
        list_short
        ;;
    --list-long)
        list_long
        ;;
    --list-name-has)
        if [ -n "$2" ]; then
            list_name_has "$2"
        else
            echo "Error: Missing <name_part> argument."
            show_help
        fi
        ;;
    --list-pid-is)
        if [ -n "$2" ]; then
            list_pid_is "$2"
        else
            echo "Error: Missing <pid> argument."
            show_help
        fi
        ;;
    --list-sched-policy-is)
        if [ -n "$2" ]; then
            list_sched_policy_is "$2"
        else
            echo "Error: Missing <policy_number> argument."
            show_help
        fi
        ;;
    *)
        show_help
        ;;
esac
