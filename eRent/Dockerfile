FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 5130 
ENV ASPNETCORE_URLS=http://+:5130
ENV TZ=Europe/Zagreb
RUN apt-get update && apt-get install -y tzdata && rm -rf /var/lib/apt/lists/*

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .

FROM build AS publish
RUN dotnet publish "eRent.WebAPI/eRent.WebAPI.csproj" -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .
COPY eRent.WebAPI/Assets ./Assets

ENTRYPOINT ["dotnet", "eRent.WebAPI.dll"]