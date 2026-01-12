codeunit 50151 "CD Handler"
{
    [ServiceEnabled]
    procedure CreateDimensions(requestBody: Text): Text
    var
        InObj: JsonObject;
    begin
        if not InObj.ReadFrom(requestBody) then
            exit(CreateErrorResponse('Invalid JSON in requestBody.'));

        exit(ProcessCreateDimensions(InObj));
    end;

    local procedure ProcessCreateDimensions(InObj: JsonObject): Text
    var
        OutObj: JsonObject;
        OutTxt: Text;
        ResultArr: JsonArray;
        DimensionName: Text[100];
        ValuesToken: JsonToken;
        ValueToken: JsonToken;
        ValueObj: JsonObject;
        DimensionValueCode: Code[20];
        DimensionValueName: Text[50];
        ResultObj: JsonObject;
        Helpers: Codeunit "CD Dimension Helpers";
        i: Integer;
        SuccessCount: Integer;
    begin
        Clear(ResultArr);
        Clear(OutObj);
        SuccessCount := 0;

        // Extract dimension name
        if not ExtractDimensionName(InObj, DimensionName) then begin
            exit(CreateErrorResponse('Missing or invalid "name" field.'));
        end;

        // Create dimension if it doesn't exist
        Helpers.CreateDimensionIfNotExists(DimensionName, DimensionName);

        // Extract and process values array
        if not InObj.Get('values', ValuesToken) or not ValuesToken.IsArray() then begin
            exit(CreateErrorResponse('Missing or invalid "values" array.'));
        end;

        // Process each value in the array
        for i := 0 to ValuesToken.AsArray().Count() - 1 do begin
            if ValuesToken.AsArray().Get(i, ValueToken) then
                if ValueToken.IsObject() then begin
                    ValueObj := ValueToken.AsObject();
                    if ExtractValueCodeAndName(ValueObj, DimensionValueCode, DimensionValueName) then begin
                        if Helpers.CreateDimensionValueIfNotExists(DimensionName, DimensionValueCode, DimensionValueName) then begin
                            SuccessCount += 1;
                            ResultObj.Add('code', DimensionValueCode);
                            ResultObj.Add('status', 'created');
                            ResultArr.Add(ResultObj);
                            Clear(ResultObj);
                        end else begin
                            SuccessCount += 1;
                            ResultObj.Add('code', DimensionValueCode);
                            ResultObj.Add('status', 'skipped');
                            ResultArr.Add(ResultObj);
                            Clear(ResultObj);
                        end;
                    end;
                end;
        end;

        OutObj.Add('success', true);
        OutObj.Add('dimension', DimensionName);
        OutObj.Add('processed', SuccessCount);
        OutObj.Add('results', ResultArr);

        OutObj.WriteTo(OutTxt);
        exit(OutTxt);
    end;

    local procedure CreateErrorResponse(ErrorMsg: Text): Text
    var
        OutObj: JsonObject;
        OutTxt: Text;
    begin
        OutObj.Add('success', false);
        OutObj.Add('error', ErrorMsg);
        OutObj.WriteTo(OutTxt);
        exit(OutTxt);
    end;

    local procedure ExtractDimensionName(InObj: JsonObject; var DimensionName: Text[100]): Boolean
    var
        NameToken: JsonToken;
    begin
        if not InObj.Get('name', NameToken) or not NameToken.IsValue() then
            exit(false);

        DimensionName := CopyStr(NameToken.AsValue().AsText(), 1, MaxStrLen(DimensionName));
        exit(DimensionName <> '');
    end;

    local procedure ExtractValueCodeAndName(ValueObj: JsonObject; var DimensionValueCode: Code[20]; var DimensionValueName: Text[50]): Boolean
    var
        CodeToken: JsonToken;
        NameToken: JsonToken;
    begin
        if not ValueObj.Get('code', CodeToken) or not CodeToken.IsValue() then
            exit(false);

        DimensionValueCode := CopyStr(CodeToken.AsValue().AsText(), 1, MaxStrLen(DimensionValueCode));

        if DimensionValueCode = '' then
            exit(false);

        // Name is optional
        if ValueObj.Get('name', NameToken) and NameToken.IsValue() then
            DimensionValueName := CopyStr(NameToken.AsValue().AsText(), 1, MaxStrLen(DimensionValueName))
        else
            DimensionValueName := DimensionValueCode;

        exit(true);
    end;
}
