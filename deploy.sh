terraform apply --auto-approve
git clone https://git-codecommit.us-east-1.amazonaws.com/v1/repos/wildrydes-site
cd wildrydes-site
aws s3 cp s3://wildrydes-us-east-1/WebApplication/1_StaticWebHosting/website ./ --recursive
git add .
git commit -m 'new'
git push

