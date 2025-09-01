#!/bin/bash

# Task Manager Script
# This script helps manage and execute tasks defined in a task list.

TASK_FILE="./data/task_list.txt"

# Function to display the task list
show_tasks() {
  if [ ! -f "$TASK_FILE" ]; then
    echo "No tasks found. Create a task list file: $TASK_FILE"
    return
  fi
  cat "$TASK_FILE"
}

# Function to add a task to the list
add_task() {
  if [ -z "$1" ]; then
    echo "Usage: add_task <task_description>"
    return
  fi
  echo "- [ ] $1" >> "$TASK_FILE"
  echo "Task added: $1"
}

# Function to mark a task as complete
complete_task() {
  if [ -z "$1" ]; then
    echo "Usage: complete_task <task_number>"
    return
  fi
  if [ ! -f "$TASK_FILE" ]; then
    echo "No tasks found. Create a task list file: $TASK_FILE"
    return
  fi

  TASK_NUMBER=$1
  LINE=$(sed "${TASK_NUMBER}q;d" "$TASK_FILE")

  if [ -z "$LINE" ]; then
    echo "Task number $TASK_NUMBER not found."
    return
  fi

  NEW_LINE=$(echo "$LINE" | sed 's/- \[ \]/[x]/')
  sed -i "${TASK_NUMBER}s/.*/${NEW_LINE}/" "$TASK_FILE"
  echo "Task $TASK_NUMBER marked as complete."
}

# Main script logic
case "$1" in
  show)
    show_tasks
    ;;
  add)
    add_task "${@:2}"
    ;;
  complete)
    complete_task "$2"
    ;;
  *)
    echo "Usage: $0 [show|add <task_description>|complete <task_number>]"
    show_tasks
    ;;
esac
