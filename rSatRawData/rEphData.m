function [e1, e2]=rEphData(path)
e1=readEphDataFromFile(path+"1/raw2.csv");
e2=readEphDataFromFile(path+"2/raw2.csv");
end