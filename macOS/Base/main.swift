//
//  main.swift
//  Marconio (iOS)
//
//  Created by Brian Michel on 1/25/23.
//
import AppKit

let app = NSApplication.shared
let delegate = MarconioMacAppDelegate()
app.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
