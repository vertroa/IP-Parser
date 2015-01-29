#!/usr/bin/env ruby

require 'slop'

opts = Slop.parse do |o|
    o.string '-f', '--file', 'input filename'
    o.bool '-o', '--output', 'output results to terminal'
    o.string '-w', '--write', 'write output to filename'
    o.on '-h', '--help', 'display help' do
        puts o
        exit
    end
end

def ip_parser(file, matches)
    ip_regex = Regexp.union(/(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}/)

    file.each do |line|
        line.split.each do |word|
            match = ip_regex.match(word)
            matches.push(match.string) if match != nil
        end
    end
end

def ip_sort(matches, internals, externals)
    matches.each do |ip|
        case ip
        when /127\..\..\../
            internals.push(ip)
        when /172\..\..\../
            internals.push(ip)
        when /192\.168\..\../
            internals.push(ip)
        when /10\..\..\../
            internals.push(ip)
        else
            externals.push(ip)
        end
    end
end

def display_output(internals, externals)
    internals.each do |ip|
        p ip
    end

    externals.each do |ip|
        p ip
    end
end

def write_ouput(output_file, internals, externals)
    open(output_file, 'w') do |f|
        internals.each do |ip|
            f << ip + "\n"
        end

        externals.each do |ip|
            f << ip + "\n"
        end
    end
end

internals = []
externals = []
matches = []

if opts[:file] == nil
    p "A filename is required. ex: ruby pull_ip.rb -f apples"
    exit
end

if opts[:output] == false && opts[:write] == nil
    p "You must supply an output option, either -o or -w"
    exit
end

begin
    file = File.open(opts[:file],"r")
rescue
    p "No file found matching #{opts[:file]}"
    exit
end

ip_parser(file.readlines, matches)
ip_sort(matches, internals, externals)

if opts[:output] == true
    display_output(internals, externals)
end

if opts[:write] != nil
    write_ouput(opts[:write], internals, externals)
end
