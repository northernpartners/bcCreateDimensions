codeunit 50150 "CD Dimension Helpers"
{
    /// <summary>
    /// Creates a dimension and dimension value if they don't already exist
    /// </summary>
    procedure CreateDimensionIfNotExists(DimensionCode: Code[20]; DimensionName: Text[100])
    var
        Dimension: Record "Dimension";
    begin
        if not Dimension.Get(DimensionCode) then begin
            Dimension.Init();
            Dimension.Validate("Code", DimensionCode);
            Dimension.Validate("Name", DimensionName);
            Dimension.Insert(true);
        end;
    end;

    /// <summary>
    /// Creates a dimension value if it doesn't already exist.
    /// Returns true if created, false if already existed.
    /// </summary>
    procedure CreateDimensionValueIfNotExists(DimensionCode: Code[20]; DimensionValueCode: Code[20]; DimensionValueName: Text[50]): Boolean
    var
        DimensionValue: Record "Dimension Value";
    begin
        if DimensionValueCode = '' then
            exit(false);

        if not DimensionValue.Get(DimensionCode, DimensionValueCode) then begin
            DimensionValue.Init();
            DimensionValue.Validate("Dimension Code", DimensionCode);
            DimensionValue.Validate("Code", DimensionValueCode);
            if DimensionValueName <> '' then
                DimensionValue.Validate("Name", DimensionValueName);
            DimensionValue.Insert(true);
            exit(true);
        end;
        exit(false);
    end;

    /// <summary>
    /// Ensures dimension value exists (create/update if needed)
    /// </summary>
    procedure EnsureDimensionValue(DimensionCode: Code[20]; DimensionValueCode: Code[20]; DimensionValueName: Text[50])
    var
        DimensionValue: Record "Dimension Value";
    begin
        if DimensionValueCode = '' then
            exit;

        if not DimensionValue.Get(DimensionCode, DimensionValueCode) then begin
            DimensionValue.Init();
            DimensionValue.Validate("Dimension Code", DimensionCode);
            DimensionValue.Validate("Code", DimensionValueCode);
            if DimensionValueName <> '' then
                DimensionValue.Validate("Name", DimensionValueName);
            DimensionValue.Insert(true);
        end else begin
            // Update name if current name is "AUTOCREATED" and new name is provided
            if (UpperCase(DelChr(DimensionValue."Name", '<>', ' ')) = 'AUTOCREATED') and (DimensionValueName <> '') then begin
                DimensionValue."Name" := DimensionValueName;
                DimensionValue.Modify(false);
            end;
        end;
    end;
}
