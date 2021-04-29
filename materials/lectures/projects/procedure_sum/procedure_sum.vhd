entity PROCEDURE_SUM is					-- deklaracja sprzegu PROCEDURE_SUM'
  port(							-- deklaracja portow
    A11, A12, A13	:in  bit_vector(3 downto 0);	-- deklaracja portów wejsciowych 'A11..3'
    A21, A22, A23	:in  bit_vector(3 downto 0);	-- deklaracja portów wejsciowych 'B11..3'
    YA1, YA2, YA3	:out bit_vector(3 downto 0);	-- deklaracja portów wyjsciowych 'YA1..3'
    YB1, YB2, YB3	:out bit_vector(2 downto 0);	-- deklaracja portów wyjsciowych 'YB1..3'
    CA1, CA2, CA3	:out bit;			-- deklaracja portów wyjsciowych YA1..3
    CB1, CB2, CB3	:out bit			-- deklaracja portów wyjsciowych YB1..3
  );
end PROCEDURE_SUM;

architecture behavioural of PROCEDURE_SUM is		-- cialo architektoniczne projektu
begin							-- czesc wykonawcza ciala projektu

  procedure_sum1_inst: entity work.PROCEDURE_SUM1(cialo) -- instancja projektu 'PROCEDURE_SUM1'
    port map (A1 => A11, A2 => A21, YA => YA1, CA => CA1, YB => YB1, CB => CB1); -- przypisanie portom sygnalow

  procedure_sum2_inst: entity work.PROCEDURE_SUM2(cialo) -- instancja projektu 'PROCEDURE_SUM2'
    port map (A1 => A12, A2 => A22, YA => YA2, CA => CA2, YB => YB2, CB => CB2); -- przypisanie portom sygnalow

  procedure_sum3_inst: entity work.PROCEDURE_SUM3(cialo) -- instancja projektu 'PROCEDURE_SUM3'
    port map (A1 => A13, A2 => A23, YA => YA3, CA => CA3, YB => YB3, CB => CB3); -- przypisanie portom sygnalow

end behavioural;					-- zakonczenie ciala architektonicznego
