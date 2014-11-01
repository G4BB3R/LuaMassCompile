-- Windows Only # Sorry :( 

local DEBUG                        = false
local MAKE_BACKUP_OF_EACH_LUA_FILE = false
local COMPILER_NAME                = 'luac5.1.exe'

-- Função responsável por compilar e criptografar o arquivo .LUA, sem volta
function compile_lua(input_file, output_file)
  local comando_compile = string.format('%s -o "%s" "%s"', COMPILER_NAME, output_file, input_file)
  print('> ' .. comando_compile)
  os.execute(comando_compile)
end

-- Função para executar o script LUA, não usada neste projeto mais.
function execute_lua(file_to_execute)
  local comando_execute = 'lua5.1.exe "' .. file_to_execute .. '"'
  print('> ' .. comando_execute)
  os.execute(comando_execute)
end

-- Pelo comando `dir` no cmd.exe do Windows, filtra as pastas entre os arquivos de determinada pasta 
function scandir(path)
  local t = {}
  for filename in io.popen('dir "' .. path .. '"'):lines() do
    local result = {string.match(filename, '^(%d%d\/%d%d\/%d%d%d%d)%s+(%d%d\:%d%d)%s+(\<DIR\>)%s+(.+)$')}  
    local folder = #result > 0 and result[4]
    if folder and folder ~= '.' and folder ~= '..' then
      table.insert(t, folder)
      if DEBUG then
        print('>' .. folder)      
      end      
    end
  end
  return t
end

-- Pelo comando `dir` no cmd.exe do Windows, filtra os arquivos de determinada extensão em uma determinada pasta
function scanfile(path, extension)
  local t = {}
  for filename in io.popen('dir "' .. path .. '"'):lines() do
    local result = {string.match(filename, '^(%d%d\/%d%d\/%d%d%d%d)%s+(%d%d\:%d%d)%s+(%d+\.?%d+)%s+(.+\.' .. extension .. ')$')}  
    local folder = #result > 0 and result[4]
    if folder then
      table.insert(t, folder)
      if DEBUG then
        print('@' .. folder)
      end      
    end
  end
  return t
end

-- Retorna uma tabela com todos os arquivos de extensão .lua de determinada pasta
function getLuaFiles(path)
  local retorno = {}    
  
  -- Procurar por arquivos
  local files = scanfile(path, 'lua')
  for _, file in pairs(files) do
    table.insert(retorno, {path = path, name = file})
  end  
  
  -- Procurar por pastas 
  local folders = scandir(path)
  for index, folder in pairs(folders) do    
    local files = getLuaFiles(path .. '\\' .. folder)
    for _, file in pairs(files) do
      table.insert(retorno, {path = file.path, name = file.name})
    end  
  end      
  
  return retorno 
end 

-- Confirmações para evitar perdas
print('NUNCA EM HIPOTESE ALGUMA USE ESSE PROGRAMA DIRETAMENTE NO DROPBOX!!!!!!!!')
print('TODOS OS SEUS ARQUIVOS .LUA DENTRO DA PASTA `COMPILE` E DE SUAS SUB-PASTAS SERAO CRIPTOGRAFADOS E VOCE NAO CONSEGUIRA MAIS DESCRIPTOGRAFA-LOS.\nTEM CERTEZA ? [Y/N]')
local response = io.read()
if response:lower() ~= 'y' then
  print('Aborted.')
  return
end 

print('COLOQUE A(s) PASTA(s) QUE DESEJA TER OS ARQUIVOS .LUA CRIPTOGRAFADOS DENTRO DA PASTA `COMPILE` E PROSSIGA.')
print('LEMBRE-SE DE MANTER UMA COPIA ORIGINAL DA PASTA POIS ESTA TERA OS ARQUIVOS .LUA CRIPTOGRAFADOS SEM VOLTA!!!!')
print('PROSSEGUIR ? [Y/N].')
local response = io.read()
if response:lower() ~= 'y' then
  print('Aborted.')
  return
end

-- Para cada arquivo .LUA encontrado: imprime a info `{path, name}`, faz backup ou não de acordo com a configuração inicial,
--   e compila o arquivo usando o compilador configurado   
local files = getLuaFiles('compile', true)
for _, file in pairs(files) do
  print(string.format('{`%s`,\t`%s`}', file.path, file.name))
  local file_str = file.path .. '\\' .. file.name
  if MAKE_BACKUP_OF_EACH_LUA_FILE then
    os.execute(string.format('copy "%s" "%s"', file_str, file_str .. '.backup'))
  end
  compile_lua(file_str, file_str)    
end
  
