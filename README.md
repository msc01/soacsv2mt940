# soacsv2mt940

[![](https://codescene.io/projects/5637/status.svg) Get more details at **codescene.io**.](https://codescene.io/projects/5637/jobs/latest-successful/results)

## Description

Convert bank Statement Of Account (SOA) .CSV file to mt940 (swift format) file.

## Synopsis

    soacsv2mt940 -c, --csv <file> [-m, --mt940 <file>] [-n, --nbr <number>] [-b, --balance <amount>] [-f, --format <format>]

Example:

    soacsvmt940 -c bank.csv --mt940 bank.txt -n 001 --balance -1523,89 -f commerzbank

Arguments:

- `-c, --csv <filename>`: Name of the .csv input file which needs to be converted to the mt940 format.
- `-m, --mt940 <filename>`: Optional name of the output file; if not given der the appendix .mt940 will be added to the file name of the input file.
- `-n, --nbr <number>`: Optional number of the statement of account which will be written to record type :28c: of the mt940 file. Defaults to 0 if not given.
- `-b, --balance <amount>`: Optional opening balance of the statement of account. Defaults to 0 if not given.
- `-f, --format <format>`: Optional format of the .csv file. Could be either commerzbank or 1822direkt. Defaults to commerzbank if not given.
- `-h, --help`: Show this information.

## Background

Most banks offer exporting statement of account information from their online service as [.csv files][1]. Further processing of statement of account informationn usually requires the so called swift format, which is also known as [mt940][2] (further [details][3], an [example mt940 file][4]).

This programm converts a given statement of account .csv export file into a swift mt940 file.

## ToDo

- Suppress / aggregate logging info for records not processed when not in debug mode.
- Add VR-Bank format.

---

[1]:data/test.csv
[2]:http://de.wikipedia.org/wiki/MT940
[3]:data/datenstruktur-mt940-swift.pdf
[4]:data/soamt940_test_template.mt940