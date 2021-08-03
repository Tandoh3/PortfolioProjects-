/* 
Cleaning Data in SQL Queries 

*/

Select * 
From PortfolioProject.dbo.NashvilleHousing 



----------Standardize Date Format 

Select SaleDateConverted, CONVERT (Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing 


Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing 
Add SaleDateConverted Date;


Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)


------------------------------------- 
--Populate Property Address Data


Select *
From PortfolioProject.dbo.NashvilleHousing 
--Where PropertyAddress is null 
Order by ParcelID 

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID] <> b.[UniqueID]
	 where a.PropertyAddress is null


-----------------------------------------------------------
-- Breaking out Address Into Individual Columns (Address, City, State)
Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing 
--Where PropertyAddress is null 
--order by ParcelID

Select 
SubString(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress) -1) as Address
, SubString(PropertyAddress,  CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing 
Add PropertySplitAddress Nvarchar(255) ;


Update NashvilleHousing
SET PropertySplitAddress = SubString(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress) -1)


ALTER TABLE NashvilleHousing 
Add PropertySplitCity Nvarchar(255);


Update NashvilleHousing
SET PropertySplitCity =  SubString(PropertyAddress,  CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))


Select * 
From PortfolioProject.dbo.NashvilleHousing 


Select  OwnerAddress
From PortfolioProject.dbo.NashvilleHousing 

Select 
ParseName(Replace(OwnerAddress, ',','.') ,3) 
,ParseName(Replace(OwnerAddress, ',','.'),2) 
,ParseName(Replace(OwnerAddress, ',','.'),1) 
From PortfolioProject.dbo.NashvilleHousing 


ALTER TABLE NashvilleHousing 
Add OwnerSplitAddress Nvarchar(255) ;


Update NashvilleHousing
SET OwnerSplitAddress = ParseName(Replace(OwnerAddress, ',','.') ,3)


ALTER TABLE NashvilleHousing 
Add OwnerSplitCity Nvarchar(255);


Update NashvilleHousing
SET OwnerSplitCity =  ParseName(Replace(OwnerAddress, ',','.'),1)


ALTER TABLE NashvilleHousing 
Add OwnerSplitState Nvarchar(255);


Update NashvilleHousing
SET OwnerSplitState = ParseName(Replace(OwnerAddress, ',','.'),2)


Select * 
From PortfolioProject.dbo.NashvilleHousing 


---Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct SoldAsVacant , Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2



Select SoldAsVacant 
, Case when SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant ='N'THEN 'No'
	   ELSE SoldAsVacant
	   END 
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing 
SET SoldAsVacant =  Case when SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant ='N'THEN 'No'
	   ELSE SoldAsVacant
	   END 



-------------------------------------------------------------
--Remove Duplicates

WITH RowNumCTE AS (
Select * , 
     ROW_NUMBER() OVER (
	 PARTITION BY ParcelID,
	              PropertyAddress,
	              SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY 
				   UniqueID
				   ) row_num

From PortfolioProject.dbo.NashvilleHousing 
--order by ParcelID
)
--DELETE
--From RowNumCTE
--WHERE row_num >1 
--ORDER BY PropertyAddress

Select *
From RowNumCTE
WHERE row_num >1 
ORDER BY PropertyAddress

----------------------------------------------
--Delete Unused Columns 


Select * 
From PortfolioProject.dbo.NashvilleHousing 

ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
DROP COLUMN SaleDate


