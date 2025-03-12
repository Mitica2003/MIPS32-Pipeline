library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MEM is
    Port ( MemWrite : in STD_LOGIC;
           ALURes : in STD_LOGIC_VECTOR (31 downto 0);
           RD2 : in STD_LOGIC_VECTOR (31 downto 0);
           clk : in STD_LOGIC;
           en : in STD_LOGIC;
           MemData : out STD_LOGIC_VECTOR (31 downto 0);
           ALUResOut : out STD_LOGIC_VECTOR (31 downto 0));
end MEM;

architecture Behavioral of MEM is
type mem_t is array(0 to 63) of STD_LOGIC_VECTOR(31 downto 0);
signal MEM : mem_t := (X"00000000", -- 0
                       X"0000000C", -- 12  A
                       X"0000000A", -- 10  N
                       X"00000002", -- 2   
                       X"00000005", -- 5   
                       X"00000008", -- 8,  
                       X"0000000B", -- 11  
                       X"0000000E", -- 14  
                       X"00000011", -- 17  
                       X"00000014", -- 20  
                       X"00000017", -- 23  
                       X"0000001A", -- 26  
                       X"0000001D", -- 29  
                       others => X"00000000");

begin

    MemData <= MEM(conv_integer(ALURes(7 downto 2)));
    
    process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' and MemWrite = '1' then
                 MEM(conv_integer(ALURes(7 downto 2))) <= RD2;
            end if;
        end if;
    end process;
    
    ALUResOut <= ALURes;
    
end Behavioral;
