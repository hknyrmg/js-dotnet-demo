# Build aşaması
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Projeyi kopyala
COPY . .

# Projeyi derle ve publish et
RUN dotnet restore
RUN dotnet publish -c Release -o /app/publish --no-restore

# Runtime aşaması
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

COPY --from=build /app/publish .

ENTRYPOINT ["dotnet", "JsDotnetDemo.dll"]
